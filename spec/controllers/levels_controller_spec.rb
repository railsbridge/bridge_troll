require 'rails_helper'

describe LevelsController, type: :controller do
  let(:user) { create(:user, admin: true) }

  before do
    sign_in user
    @course = create(:course)
  end

  let(:valid_attributes) do
    {
      num: 5,
      color: 'purple',
      title: "Totally New to Programming",
      level_description: "[\"You have little to no experience with the terminal or a graphical IDE\"]"
    }
  end

  let(:invalid_attributes) {
    {
      num: "Five",
      color: 'blue',
      title: nil,
      level_description: ['You have little to no experience with the terminal or a graphical IDE']
    }
  }


  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all levels as @levels" do
      get :index, {course_id: @course.id}, valid_session
      expect(assigns(:levels)).to eq(@course.levels)
    end
  end

  describe "GET #new" do
    it "assigns a new level as @level" do
      get :new, {course_id: @course.id}, valid_session
      expect(assigns(:level)).to be_a_new(Level)
    end
  end

  describe "GET #edit" do
    it "assigns the requested level as @level" do
      level = @course.levels.first
      get :edit, {course_id: @course.id, id: level.to_param}, valid_session
      expect(assigns(:level)).to eq(level)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Level" do
        expect {
          post :create, {level: valid_attributes, course_id: @course.id}, valid_session
        }.to change(Level, :count).by(1)
      end

      it "assigns a newly created level as @level" do
        post :create, {level: valid_attributes, course_id: @course.id}, valid_session
        expect(assigns(:level)).to be_a(Level)
        expect(assigns(:level)).to be_persisted
      end

      it "redirects to the created level" do
        post :create, {level: valid_attributes, course_id: @course.id}, valid_session
        expect(response).to redirect_to(course_levels_url(@course))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved level as @level" do
        post :create, {level: invalid_attributes, course_id: @course.id}, valid_session
        expect(assigns(:level)).to be_a_new(Level)
      end

      it "re-renders the 'new' template" do
        post :create, {level: invalid_attributes, course_id: @course.id}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        {
          num: 5,
          color: 'rainbow',
          title: 'Expert',
          level_description: "[\"You are an expert.\"]"
        }
      end

      it "updates the requested level" do
        level = @course.levels.first
        put :update, {id: level.to_param, level: new_attributes, course_id: @course.id}, valid_session
        level.reload
        expect(level.color).to eq('rainbow')
        expect(level.description).to include('You are an expert.')
      end

      it "assigns the requested level as @level" do
        level = @course.levels.first
        put :update, {id: level.to_param, level: valid_attributes, course_id: @course.id}, valid_session
        expect(assigns(:level)).to eq(level)
      end

      it "redirects to the level" do
        level = @course.levels.first
        put :update, {id: level.to_param, level: valid_attributes, course_id: @course.id}, valid_session
        expect(response).to redirect_to(course_levels_url(@course))
      end
    end

    context "with invalid params" do
      it "assigns the level as @level" do
        level = @course.levels.first
        put :update, {id: level.to_param, level: invalid_attributes, course_id: @course.id}, valid_session
        expect(assigns(:level)).to eq(level)
      end

      it "re-renders the 'edit' template" do
        level = @course.levels.first
        put :update, {id: level.to_param, level: invalid_attributes, course_id: @course.id}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested level" do
      level = @course.levels.first
      expect {
        delete :destroy, {id: level.to_param, course_id: @course.id}, valid_session
      }.to change(Level, :count).by(-1)
    end

    it "redirects to the levels list" do
      level = @course.levels.first
      delete :destroy, {id: level.to_param, course_id: @course.id}, valid_session
      expect(response).to redirect_to(course_levels_url(@course))
    end
  end

end
