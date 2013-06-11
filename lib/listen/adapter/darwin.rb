module Listen
  module Adapter

    # Adapter implementation for Mac OS X `FSEvents`.
    #
    class Darwin < Base

      def self.usable?
        RbConfig::CONFIG['target_os'] =~ /darwin(1.+)?$/i
      end

      def initialize
        require 'rb-fsevent'
      end

      def start
        worker = _init_worker
        worker.run
      end

      private

      # Initializes a FSEvent worker and adds a watcher for
      # each directory listened.
      #
      def _init_worker
        FSEvent.new.tap do |worker|
          worker.watch(_directories_path, latency: _latency) do |changes|
            directories_path = changes.map { |path| path.sub(/\/$/, '') }
            directories_path.each { |path| _notify_change(path, type: 'Dir') }
          end
        end
      end

    end

  end
end