require 'net/http'

class Updater
  class << self
    def perform
      Person.all.each do |person|
       update(person)
      end
    end

    def update(person)
      limit  = 50
      offset = 1
      latest = person.favorites.first.try(:created_at)

      catch(:break) do
        loop do
          videos = get_videos(person, limit, offset)

          throw(:break) if videos.none?

          videos.each do |video|
            key = video['group']['videoid']
            title = video['title']
            created_at = video['published']

            throw(:break) if (latest && latest >= created_at)

            person.favorites.create(key: key, title: title, created_at: created_at)
          end

          offset = offset + limit
        end
      end
    end

    def get_videos(person, limit, offset)
      uri = URI.parse("http://gdata.youtube.com/feeds/api/users/#{person.username}/favorites?v=2&max-results=#{limit}&start-index=#{offset}&format=5")
      response = Net::HTTP.get_response(uri).body
      Hash.from_xml(response)['feed']['entry'] || []
    end
  end
end
