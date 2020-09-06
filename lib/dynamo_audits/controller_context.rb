module DynamoAudits
  class ControllerContext
    def around(controller)
      if controller.present?
        DynamoAudits.purge_store!
        DynamoAudits.store[:current_user] = controller.current_user if controller.respond_to?(:current_user)
        DynamoAudits.store[:current_company] = controller.current_company if controller.respond_to?(:current_company)
        DynamoAudits.store[:request_uuid] = controller.request.uuid
        DynamoAudits.store[:remote_ip] = controller.request.remote_ip
        DynamoAudits.store[:current_controller] = controller
      end
      yield
    ensure
      # reset the thread local variable.
      ActiveRecordSegment.purge_store!
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