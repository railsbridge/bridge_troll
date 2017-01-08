require 'rails_helper'

describe CoursesController, type: :controller do
  let(:user) { create(:user, admin: true) }

  before do
    sign_in user
  end

  let(:valid_attributes) do
    {
      name: 'RAILS',
      title: 'Ruby on Rails',
      description: 'This is a Ruby on Rails event.'
    }
  end

  let(:invalid_attributes) do
    {
      name: 'RAILS',
      title: nil,
      description: nil
    }
  end

  let(:valid_session) { {} }

  describe "GET #new" do
    it "assigns a new course as @course" do
      get :new, {}, valid_session
      expect(assigns(:course)).to be_a_new(Course)
    end
  end

  describe "GET #edit" do
    it "assigns the requested course as @course" do
      course = Course.create! valid_attributes
      get :edit, {:id => course.to_param}, valid_session
      expect(assigns(:course)).to eq(course)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Course" do
        expect {
          post :create, {:course => valid_attributes}, valid_session
        }.to change(Course, :count).by(1)
      end

      it "assigns a newly created course as @course" do
        post :create, {:course => valid_attributes}, valid_session
        expect(assigns(:course)).to be_a(Course)
        expect(assigns(:course)).to be_persisted
      end

      it "redirects to the created course" do
        post :create, {:course => valid_attributes}, valid_session
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved course as @course" do
        post :create, {:course => invalid_attributes}, valid_session
        expect(assigns(:course)).to be_a_new(Course)
      end

      it "re-renders the 'new' template" do
        post :create, {:course => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        {
          name: 'RAILS5',
          title: 'Ruby on Rails 5',
          description: 'This is a Ruby on Rails event. UPDATED for a new version.'
        }
      end

      it "updates the requested course" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => new_attributes}, valid_session
        course.reload
        expect(course.name).to eq('RAILS5')
      end

      it "assigns the requested course as @course" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => valid_attributes}, valid_session
        expect(assigns(:course)).to eq(course)
      end

      it "redirects to the course" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => valid_attributes}, valid_session
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "with invalid params" do
      it "assigns the course as @course" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => invalid_attributes}, valid_session
        expect(assigns(:course)).to eq(course)
      end

      it "re-renders the 'edit' template" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested course" do
      course = Course.create! valid_attributes
      expect {
        delete :destroy, {:id => course.to_param}, valid_session
      }.to change(Course, :count).by(-1)
    end

    it "redirects to the courses list" do
      course = Course.create! valid_attributes
      delete :destroy, {:id => course.to_param}, valid_session
      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

end
