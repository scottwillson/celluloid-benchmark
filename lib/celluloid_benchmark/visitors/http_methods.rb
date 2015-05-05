module CelluloidBenchmark
  module Visitors
    module HTTPMethods
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
