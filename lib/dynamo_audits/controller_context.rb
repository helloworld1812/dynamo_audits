module DynamoAudits
  class ControllerContext
    def around(controller)
      if controller.present?
        dup = controller.deep_dup
        DynamoAudits.purge_store!
        DynamoAudits.store[:current_user] =  dup.current_user if dup.respond_to?(:current_user)
        DynamoAudits.store[:current_company] = dup.current_company if dup.respond_to?(:current_company)
        DynamoAudits.store[:request_uuid] = dup.request.uuid
        DynamoAudits.store[:remote_ip] = dup.request.remote_ip
        DynamoAudits.store[:current_controller] = controller
      end
      yield
    ensure
      # reset the thread local variable.
      DynamoAudits.purge_store!
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  if defined?(ActionController::Base)
    ActionController::Base.around_action DynamoAudits::ControllerContext.new
  end
  if defined?(ActionController::API)
    ActionController::API.around_action DynamoAudits::ControllerContext.new
  end
end
