module CelluloidBenchmark
  module Visitors
    module HTTPMethods
      def get(uri, parameters = [], referer = nil, headers = {})
        page = browser.get(uri, parameters, referer, headers)
        log_response page
        page
      end

      def post(uri, query = {}, headers = {})
        page = browser.post(uri, query, headers)
        log_response page
        page
      end

      def put(uri, entity, headers = {})
        page = browser.put(uri, entity, headers)
        log_response page
        page
      end

      def get_json(uri, headers = {})
        get uri, [], nil, headers.merge("Accept" => "application/json, text/javascript, */*; q=0.01")
      end

      def post_json(uri, query, headers = {})
        post(
          uri,
          MultiJson.dump(query),
          { "Content-Type" => "application/json", "Accept" => "application/json, text/javascript, */*; q=0.01" }.merge(headers)
        )
      end

      def put_json(uri, query, headers = {})
        put(
          uri,
          MultiJson.dump(query),
          { "Content-Type" => "application/json", "Accept" => "application/json, text/javascript, */*; q=0.01" }.merge(headers)
        )
      end
    end
  end
end
