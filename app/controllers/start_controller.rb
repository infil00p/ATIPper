class StartController < ApplicationController

    def index
      if(user_signed_in?)
        redirect_to('/home/index.html')
      end
    end

end
