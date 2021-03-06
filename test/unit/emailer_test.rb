require 'test_helper'

class EmailerTest < ActiveSupport::TestCase
  setup do
    Subscriber.create! email: 'test@example.com'
    Subscriber.create! email: 'test2@example.com'

    ActionMailer::Base.deliveries.clear
  end

  test "perform sends videos created in the last 24hrs to all subscribers" do
    Video.create! key: 'key', title: 'title'
    Emailer.perform

    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  test "perform does not send old videos" do
    Video.create! key: 'key', title: 'title', created_at: 2.days.ago
    Emailer.perform

    assert_equal 0, ActionMailer::Base.deliveries.size
  end
end
