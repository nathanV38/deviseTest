class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :confirmable , :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name
  # attr_accessible :title, :body
  
  validates_confirmation_of :email, :if => :email_required?
  
  def self.from_omniauth(auth)
	where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
  end 
  
  def self.create_from_omniauth(auth)
	create! do |user|
		user.provider = auth["provider"]	
		user.uid = auth["uid"]
		
		if user.provider == "google_oauth2"  #"google_oauth2"  "identity" #fix pour google : name, pas nickname dans le json!
			user.name = auth['info']['name']
			user.skip_confirmation!
		else 
			user.name = auth["info"]["nickname"]
			user.skip_confirmation!
		end 
	end
  end
  
  def self.new_with_session(params, session)
	  if session["devise.user_attributes"]
		new(session["devise.user_attributes"], without_protection: true) do |user|
		  user.attributes = params
		  user.valid?
		end
	  else
		super
	  end    
  end


	def password_required?
		super && provider.blank?
	end

	def email_required?
		super && provider.blank?
	end
	
	def update_with_password(params, *options)
	if encrypted_password.blank?
		update_attributes(params, *options)
	else
		super
    end
	end
end
