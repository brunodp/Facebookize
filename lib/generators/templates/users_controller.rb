class UsersController < ApplicationController
  def auth
    # Si viene aceptando un request, por ahora la eliminamos y nada mas
    # va cachando excepciones porque a Lucas le fallo en algun momento
    begin
      if params[:request_ids]
        app_access_token = Koala::Facebook::OAuth.new.get_app_access_token
        graph = Koala::Facebook::GraphAPI.new(app_access_token)
        # Por ahora solo viene un request id, pero en el futuro pueden venir varios...
        params[:request_ids].split(',').each do |req_id|
          graph.delete_object(req_id)
        end
      end
    rescue
    end
        
    @oauth_url =  Koala::Facebook::OAuth.new.url_for_oauth_code(
                    :permissions => 'user_birthday, user_hometown, user_location, email, publish_stream', 
                    :callback => callback
                  )    
                
    render :layout => false
  end
  
  def logged_in
    url = "http://apps.facebook.com/#{Facebook::WORK_PAGE}/users/logged_in"
    
    begin
      access_token = Koala::Facebook::OAuth.new(url).get_access_token(params[:code]) if params[:code]
    rescue Koala::Facebook::APIError,Errno::ECONNRESET => e
      redirect_to root_url and return
    end
    
    if access_token
      session[:access_token] = access_token
      graph = Koala::Facebook::GraphAPI.new(access_token)
      # Si el usuario no tiene sesion iniciamos una
      session[:user] ||= {}

      attrs = [:id, :email, :location, :name, :first_name, :gender, :birthday]
      # Evaluamos si la sesion es necesita ser actualizada (grabar y actualizar sesion)
      missing_data = attrs.reject { |a| session[:user].keys.include? a }
      if not missing_data.empty?
        # Obtenemos los datos del usuario actual
        me = graph.get_object("me")
        
        # Guardamos
        me['ip'] = request.remote_ip
        User.new(me).save

        # Actualizamos sesion
        attrs.each do |a|
          if me[a.to_s]
            session[:user][a] = me[a.to_s]
          else
            session[:user][a] = nil
          end
        end
      end      
      
      redirect_to # REDIRECT ON SUCCESS !!!
    end
  end
  
end