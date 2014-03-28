require 'rubygems'
require 'rest-client'

module Replication

  # A wrapper class based on {RestClient} used to interface with the Archive Catalog service.
  # <br>
  # <br>
  # The default RestClient behavior is:
  # * for results code between 200 and 207 a RestClient::Response will be returned
  # * for results code 301, 302 or 307 the redirection will be followed if the request is a get or a head
  # * for result code 303 the redirection will be followed and the request transformed into a get
  # * for other cases a RestClient::Exception holding the Response will be raised
  #
  # But we are using a technique that forces RestClient to always provide the response
  # <br>
  # <br>
  # RestClient::Response has these instance methods (some inherited from AbstractResponse):
  # * args
  # * body
  # * code (e.g. 204)
  # * description (e.g. "204 No Content |  0 bytes")
  # * headers
  # * net_http_res
  #
  # @see https://github.com/rest-client/rest-client
  # @see http://rubydoc.info/gems/rest-client/1.6.7/frames
  class ArchiveCatalog

    @root_uri = 'http://localhost:3000'
    @timeout = 120

    # @see https://www.google.com/search?q="class+<<+self"+"attr_accessor"
    class << self

      # @return [String] The base or home URL of the Archive Catalog web service
      attr_accessor :root_uri

      # @return [Integer] seconds to wait for a response or to open a connection. Value nil disables the timeout.
      attr_accessor :timeout

      # The base RestClient resource to be used for requests
      def root_resource
        RestClient::Resource.new(@root_uri, {:open_timeout => @timeout, :timeout => @timeout})
      end

      # Get the item record from the specified table for the specified primary key.
      # @param [String] table name of the database table
      # @param [String] id primary key for the item in the database table
      # @return [Hash] the row (in key,value hash) from the specified table for the specified identifier.
      #    Response body contains the item data in JSON format, which is converted to a hash.
      # @see http://tools.ietf.org/html/rfc2616#page-53
      def get_item(table,id)
        # Don't raise RestClient::Exception but return the response
        headers = {:accept => 'application/json'}
        response = root_resource["#{table}/#{id}.json"].get(headers) {|response, request, result| response }
        case response.code.to_s
          when '200'
            JSON.parse(response.body)
          else
            raise response.description
        end
      end

      # Retrieve an existing database record or add a new one using the data provided.
      # @param [String] table name of the database table
      # @param [Hash] hash the item data to be added to the database table
      # @return [Hash] result containing the item data as if a GET were performed.
      #    The HTTP response code for success is 201 (Created).
      # @see http://en.wikipedia.org/wiki/POST_(HTTP)
      # @see http://tools.ietf.org/html/rfc2616#page-54
      def find_or_create_item(table,hash)
        payload = hash.to_json
        headers = {:content_type => :json, :accept => :json}
        # Don't raise RestClient::Exception but return the response
        response = root_resource["#{table}.json"].post(payload, headers) {|response, request, result| response }
        case response.code.to_s
          when '201'
            JSON.parse(response.body)
          else
            raise response.description
        end
      end

      # Update the database columns for the specified item using the hash data.
      # @param [String] table name of the database table
      # @param [String] id primary key for the item in the database table
      # @param [Hash] hash the item data to be updated in the database table
      # @return (Boolean) true if the HTTP response code is 204, per specification for PATCH or PUT request types.
      #    Response body is empty, per same specification.
      # @see https://tools.ietf.org/html/rfc5789
      # @see http://stackoverflow.com/questions/797834/should-a-restful-put-operation-return-something/827045#827045
      def update_item(table,id,hash)
        payload = hash.to_json
        headers = {:content_type => :json}
        # Don't raise RestClient::Exception but return the response
        response = root_resource["#{table}/#{id}.json"].patch(payload, headers) {|response, request, result| response }
        case response.code.to_s
          when '204'
            true
          else
            raise response.description
        end
      end

    end

  end

end