require 'test_helper'

class GitHub::Deprecation::DelayedQueueTest < Test::Unit::TestCase
  def subject
    @subject ||= GitHub::Deprecation::DelayedQueue.new
  end

  def setup
    subject.clear
  end

  def test_enqueue
    subject.enqueue 'giraffe', 'hippo'
    assert_equal 2, subject.size
  end

  def test_start_processes_queued_items
    item = 'fish'
    subject.enqueue(item)
    subject.start! {|e| e.upcase!}
    assert_equal 'FISH', item
  end

  def test_start_processes_future_items
    subject.start! {|e| e.upcase!}
    item = 'turtle'
    subject.enqueue(item)
    assert_equal 'TURTLE', item
  end

  def test_pause
    fish   = 'fish'
    turtle = 'turtle'
    subject.enqueue(fish)
    subject.start! {|e| e.upcase!}
    subject.pause!
    subject.enqueue(turtle)
    assert_equal 'FISH', fish
    assert_equal 'turtle', turtle
  end
end