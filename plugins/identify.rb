# -*- coding: utf-8 -*-
require 'openssl'

module Cinch
  module Plugins
    # Automagick nickserv identification
    # downloaded from https://github.com/cinchrb/cinch-identify
    class Identify
      include Cinch::Plugin

      listen_to :connect, method: :identify
      def identify(*)
        case config[:type]
        when :quakenet
          debug 'Identifying with Q'
          identify_quakenet
        when :dalnet
          debug 'Identifying with Nickserv on DALnet'
          identify_dalnet
        when :secure_quakenet, :challengeauth
          debug 'Identifying with Q, using CHALLENGEAUTH'
          identify_secure_quakenet
        when :nickserv
          debug 'Identifying with NickServ'
          identify_nickserv
        when :kreynet
          debug 'Identifying with K on KreyNet'
          identify_kreynet
        when :userserv
          debug 'Identifying with UserServ'
          identify_userserv
        else
          debug "Cannot identify with unknown type #{config[:type].inspect}"
        end
      end

      match(/^You are successfully identified as/,
            use_prefix: false, use_suffix: false, react_on: :private,
            method: :identified_nickserv)
      match(/^You are now identified for/,
            use_prefix: false, use_suffix: false, react_on: :private,
            method: :identified_nickserv)
      match(/^Password accepted - you are now recognized\./,
            use_prefix: false, use_suffix: false, react_on: :private,
            method: :identified_nickserv)
      match(/^Hasło przyjęte - jesteś zidentyfikowany/,
            use_prefix: false, use_suffix: false, react_on: :private,
            method: :identified_nickserv)
      def identified_nickserv(m)
        service_name = config[:service_name] || 'nickserv'
        return unless m.user == User(service_name) &&
                      config[:type] == :nickserv
        debug 'Identified with NickServ'
        @bot.handlers.dispatch :identified, m
      end

      match(/^CHALLENGE (.+?) (.+)$/,
            use_prefix: false, use_suffix: false, react_on: :notice,
            method: :challengeauth)
      def challengeauth(m)
        return unless m.user && m.user.nick == 'Q'
        return unless [:secure_quakenet, :challengeauth].include?(config[:type])

        match = m.message.match(/^CHALLENGE (.+?) (.+)$/)
        return unless match
        challenge = match[1]
        @bot.debug "Received challenge '#{challenge}'"

        username = config[:username].irc_downcase(:rfc1459)
        password = config[:password][0, 10]

        key = OpenSSL::Digest::SHA256.hexdigest(
          username + ':' + OpenSSL::Digest::SHA256.hexdigest(password)
        )
        response = OpenSSL::HMAC.hexdigest('SHA256', key, challenge)
        User('Q@CServe.quakenet.org').send(
          "CHALLENGEAUTH #{username} #{response} HMAC-SHA-256"
        )
      end

      match(/^You are now logged in as/,
            use_prefix: false, use_suffix: false, react_on: :notice,
            method: :identified_quakenet)
      def identified_quakenet(m)
        return unless m.user == User('q') &&
                      [:quakenet, :secure_quakenet, :challengeauth].include?(
                        config[:type]
                      )
        debug 'Identified with Q'
        @bot.handlers.dispatch(:identified, m)
      end

      match(/^You are now logged in as/,
            use_prefix: false, use_suffix: false, react_on: :notice,
            method: :identified_userserv)
      def identified_userserv(m)
        service_name = config[:service_name] || 'UserServ'
        service_name = service_name.split('@').first
        return unless m.user == User(service_name) && config[:type] == :userserv
        debug 'Identified with UserServ'
        @bot.handlers.dispatch :identified, m
      end

      private

      def identify_dalnet
        User('Nickserv@services.dal.net').send(
          format('identify %s', config[:password])
        )
      end

      def identify_quakenet
        User('Q@CServe.quakenet.org').send(
          format('auth %s %s', config[:username], config[:password])
        )
      end

      def identify_secure_quakenet
        User('Q@CServe.quakenet.org').send('CHALLENGE')
      end

      def identify_nickserv
        service_name = config[:service_name] || 'nickserv'
        service_name = service_name.split('@').first
        cmd = if config[:username]
                format('identify %s %s', config[:username], config[:password])
              else
                format('identify %s', config[:password])
              end
        User(service_name).send(cmd)
      end

      def identify_kreynet
        User('K!k@krey.net').send(
          format('LOGIN %s %s', config[:username], config[:password])
        )
      end

      def identify_userserv
        service_name = config[:service_name] || 'UserServ'
        User(service_name).send(
          format('LOGIN %s %s', config[:username], config[:password])
        )
      end
    end
  end
end
