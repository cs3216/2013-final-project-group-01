class MasqueradesController < ApplicationController
  load_and_authorize_resource :user, only: [:new]
  before_filter :authorize_masquerade

  def authorize_masquerade
    puts 'Check if user is able to masquerade before proceed..'
    masquerading? || authorize!(:masquerade, :user)
  end

  def new
    if !masquerading?
      session[:admin_id] = current_user.id
    end
    user = User.find(params[:user_id])
    sign_in user

    log = MasqueradeLog.new
    log.by_user_id = session[:admin_id]
    log.as_user_id = params[:user_id]
    log.action = 'login'
    log.save

    redirect_to root_path, notice: "Now masquerading as #{user.name}"
  end

  def destroy
    log = MasqueradeLog.new
    log.by_user_id = session[:admin_id]
    log.as_user_id = current_user ? current_user.id : nil
    log.action = 'login'
    log.save

    user = User.find(session[:admin_id])
    sign_in user
    session[:admin_id] = nil
    redirect_to admin_masquerades_path, notice: "Stopped masquerading"
  end
end
