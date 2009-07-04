module OldYeller
  class Test < Test::Unit::TestCase
  class << self
    @@controller_params = {}
    # set params controller wide
    def controller(name, params = {})
      @@controller_params[name.to_s] = params
    end
  
    @@action_params = {}
    # set params for an action
    def action(controller_name, action_name, params = {})
      controller_name = controller_name.to_s
      @@action_params[controller_name] ||= {}
      @@action_params[controller_name].merge!({action_name.to_s => params})
    end
  
    @@excluded_controllers = []
    def exclude_controller(name)
      @@excluded_controllers << name.to_s
    end
  
    @@excluded_actions = {}
    def exclude_action(controller_name, action_name)
      controller_name = controller_name.to_s
      @@excluded_actions[controller_name] ||= []
      @@excluded_actions[controller_name] << action_name.to_s
    end

    @@excluded_methods = []
    def exclude_method(name)
      @@excluded_methods << name.to_s
    end

    @@setup_code = nil
    def setup_code(code)
      @@setup_code = code
    end

    def detect_dead_code
      #hook in template detection
      ActionView::Template.send(:include, OldYeller::TemplateRecording)

      ActionController::Routing::Routes.routes.each do |route|
        generate_tests_for_route(route)
      end
    end
  
    protected

    def generate_tests_for_route(route)
      controller, action, method = get_route_path(route)
      
      if !controller || !action ||
        route.significant_keys.include?(:format) ||
        @@excluded_controllers.include?(controller) || 
        ((a = @@excluded_actions[controller]) && a.include?(action)) || 
        @@excluded_methods.include?(method.to_s)

        return
      end


      params = generate_params(route, controller, action)


      puts
      puts controller
      puts action
      p params
      puts 
      puts

      generate_test(route, controller,  action, method, params)
    end

    def generate_test(route, controller, action, method, params)
      controller_class = "#{controller.camelize}Controller".constantize
      setup_code = @@setup_code
      context "on route #{method} #{route.segments.map(&:to_s).inject(&:+)}" +
        "(#{controller}##{action} with #{params.inspect})" do
        setup do
          @controller = controller_class.new
          @request = ActionController::TestRequest.new
          @response = ActionController::TestResponse.new

          eval(setup_code) if setup_code
        end
        
        should "work" do
          send(method, action, params)
          assert_response :success
        end
      end
    end

    def get_route_path(route)
      [route.defaults[:controller],
       action = route.defaults[:action],
       method = route.conditions[:method] || :get]
    end

    def generate_params(route, controller, action)
      params = route.defaults.merge((route.significant_keys - route.defaults.keys).map do |i|
        [i, 
          ((a = @@action_params[controller]) && (b = a[action]) && b[i]) || 
          ((a = @@controller_params[controller]) && a[i]) || infer_param(controller, action, i)]
      end.inject({}) do |h, i|
        h[i[0]] = i[1]
        h
      end).merge(((a = @@action_params[controller]) && a[action]) || {}).
        merge(@@controller_params[controller] || {})

      params.delete(:action)
      params.delete(:controller)
      params
    end

  
    def infer_param(c, a, p)
      if p == :id
        model = c.gsub(/^(.*\/)/, '').camelize.singularize.constantize
        p model
        p model.first
        model.first.to_param
      elsif p == :format
        (a.match(/^js/)) ? :js : :rss
      elsif p == :page
        1
      else
        raise "Uninferable parameter #{p} for #{c}##{a}"
      end
    rescue
      raise "Uninferable parameter #{p} for #{c}##{a}"
    end
  end
  end
end
