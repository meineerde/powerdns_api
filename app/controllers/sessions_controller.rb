class SessionsController < Devise::SessionsController
  def sign_in
    render :text => "Hallo"
  end
end
