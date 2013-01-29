shared_examples_for "an action that requires user log-in" do
  it "does not allow access to anonymous users" do
    make_request
    response.should redirect_to(new_user_session_path)
  end
end

shared_examples_for "an event action that requires an organizer" do
  it "does not allow access to anonymous users" do
    make_request
    response.should redirect_to(new_user_session_path)
  end

  it "does not allow access to users who aren't organizers of the event" do
    sign_in(create(:user))
    make_request
    response.should redirect_to(events_path)
  end
end
