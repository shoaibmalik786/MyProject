class UsersAutocomplete
	def initialize(app)
		@app = app
	end

	def call(env)
		if env["PATH_INFO"] == "/users_autocomplete"
			request = Rack::Request.new(env)
			users = User.autocomplete_for(request.params["q"])
			[200, {"Content-Type" => "application/json"}, [users.to_json]]
		else
			@app.call(env)
		end
	end
end