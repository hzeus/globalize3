require File.expand_path('../../test_helper', __FILE__)

class DirtyTrackingTest < Test::Unit::TestCase
  test "dirty tracking works" do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = 'changed title'
    assert_equal ['title'], post.translation.changed

    post.content = 'changed content'
    assert_included 'title', post.translation.changed
    assert_included 'content', post.translation.changed
  end

  test "dirty tracking is not triggered when attribute does not change" do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.translation.changed

    post.title = 'title'
    assert_equal [], post.translation.changed
  end

  test 'dirty tracking works per a locale' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.translation.changed

    post.title = 'changed title'
    assert_equal({ 'title' => ['title', 'changed title'] }, post.translation.changes)
    post.save

    I18n.locale = :de
    assert_equal nil, post.title

    post.title = 'Titel'
    assert_equal( [nil, 'Titel'] , post.translation.changes['title'])
  end

  test 'dirty tracking works on sti model' do
    child = Child.create(:content => 'foo')
    assert_equal [], child.changed

    child.content = 'bar'
    assert_equal ['content'], child.translation.changed

    child.content = 'baz'
    assert_included 'content', child.translation.changed
  end

  test 'dirty tracking works for blank assignment' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.translation.changed

    post.title = ''
    assert_equal({ 'title' => ['title', ''] }, post.translation.changes)
    post.save
  end

  test 'dirty tracking works for nil assignment' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = nil
    assert_equal({ 'title' => ['title', nil] }, post.translation.changes)
    post.save
  end

end
