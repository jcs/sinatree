require "net/smtp"

module Mailer
  @@options = {}

  def self.options=(opts)
    @@options = opts
  end

  def self.options
    @@options
  end

  def self.mail(opts = {})
    opts = @@options.merge(opts)
    from = opts[:from] || "nobody@example.com"
    to = Array(opts[:to])
    subject = opts[:subject] || ""
    body = opts[:body] || ""

    message = <<~MSG
      From: #{from}
      To: #{to.join(", ")}
      Subject: #{subject}
      Date: #{Time.now.rfc2822}
      MIME-Version: 1.0
      Content-Type: text/plain; charset=UTF-8

      #{body}
    MSG

    if !App.production?
      App.logger.info "Mailer would be sending from #{from} to #{to}:"
      message.split("\n").each{ App.logger.info "  #{it}" }
      return
    end

    case (opts[:via] || :smtp)
    when :sendmail
      IO.popen([ "sendmail", "-t", "-f", from ], "w") do |io|
        io.write(message)
      end
    when :smtp
      vo = opts[:via_options] || {}
      host = vo[:host] || "localhost"
      port = vo[:port] || 25
      smtp = Net::SMTP.new(host, port)
      if vo[:openssl_verify_mode]
        smtp.enable_tls(OpenSSL::SSL::SSLContext.new.tap do |ctx|
          ctx.verify_mode = vo[:openssl_verify_mode]
        end)
      end
      smtp.start do |s|
        s.send_message(message, from, to)
      end
    else
      raise "unsupported mailer style #{opts[:via].inspect}"
    end
  end
end
