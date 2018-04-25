require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:headers) do
    {
      'Accept' => 'application/vnd.taskmanager.v1',
      'Content-Type' => Mime[:json].to_s
    }
  end

  before { host! 'api.taskmanager.test'}

  describe 'GET /users/:id' do
    before do
      get "/users/#{user_id}", params: {}, headers: headers
    end

    context 'when the user exists' do
      it 'returns the user' do
        expect(json_body[:id]).to eq(user_id)
      end
       
      it 'returns status 200' do
        expect(response).to have_http_status(200)
      end
    end
    
    context 'when the user does not exists' do
      let(:user_id) { 10000 }
      it 'returns status 404' do
        expect(response).to have_http_status(404)
      end
    end
  end #fim do describe 'GET /users/:id'


  describe 'POST /users' do
    
    before do
      post '/users', params: { user: user_params }.to_json, headers: headers
    end
    
    context 'when the request params are valid' do
      let(:user_params) { attributes_for(:user) }

      it 'return status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'return jason data for the created user' do
        expect(json_body[:email]).to eq(user_params[:email])
      end

    end #fim do context 'when the request params are valid'

    context 'when the request params are invalid' do
      let(:user_params) { attributes_for(:user, email: 'invalid_email@') }

      it'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns the json data fo the erros' do
        expect(json_body).to have_key(:errors) 
      end 
    end #fim do context 'when the request params are invalid'
  end #fim do describ 'POST /users'

  describe 'PUT /users/:id' do
    before do
      put "/users/#{user_id}", params: {user: user_params}.to_json, headers: headers
    end

    context 'when the request params are valid' do
      let(:user_params) { { email: 'new_email@taskmanager.com' } }
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'returns the json data for the update user' do
        user_reponse = JSON.parse(response.body, symbolize_names: true)
        expect(user_reponse[:email]).to eq(user_params[:email])
      end
    end
    
    context 'when the request params are invalid' do
      let(:user_params) { { email: 'invalid_email@' } }

      it'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns the json data fo the erros' do
        expect(json_body).to have_key(:errors) 
      end 
    end #fim do context 'when the request params are invalid'
  end #fim do describe 'PUT /users/:id'

describe 'DELETE /users/:id' do
  before do
    delete "/users/#{user_id}", params: {}, headers: {} 
  end
  it 'returns status code 204' do
    expect(response).to   have_http_status(204)
  end

  it 'remove from users database' do
    expect(User.find_by(id: user.id)).to be_nil
  end
end

end #FIM DO RSpec.describe 'Users API'