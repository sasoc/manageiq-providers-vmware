class ManageIQ::Providers::Vmware::CloudManager < ManageIQ::Providers::CloudManager
  require_nested :AvailabilityZone
  require_nested :OrchestrationServiceOptionConverter
  require_nested :OrchestrationStack
  require_nested :OrchestrationTemplate
  require_nested :EventCatcher
  require_nested :EventParser
  require_nested :RefreshParser
  require_nested :RefreshWorker
  require_nested :Refresher
  require_nested :Template
  require_nested :Vm

  include ManageIQ::Providers::Vmware::ManagerAuthMixin
  include ManageIQ::Providers::Vmware::CloudManager::ManagerEventsMixin
  include HasNetworkManagerMixin

  before_create :ensure_managers

  def ensure_network_manager
    build_network_manager(:type => 'ManageIQ::Providers::Vmware::NetworkManager') unless network_manager
  end

  def self.ems_type
    @ems_type ||= "vmware_cloud".freeze
  end

  def self.description
    @description ||= "VMware vCloud".freeze
  end

  def self.default_blacklisted_event_names
    []
  end

  def self.hostname_required?
    true
  end

  def supports_port?
    true
  end

  def supported_auth_types
    %w(default amqp)
  end

  def supports_authentication?(authtype)
    supported_auth_types.include?(authtype.to_s)
  end

  def supported_catalog_types
    %w(vmware)
  end

  #
  # Operations
  #

  def vm_start(vm, _options = {})
    vm.start
  rescue => err
    $vcloud_log.error("vm=[#{vm.name}, error: #{err}")
  end

  def vm_stop(vm, _options = {})
    vm.stop
  rescue => err
    $vcloud_log.error("vm=[#{vm.name}, error: #{err}")
  end

  def vm_suspend(vm, _options = {})
    vm.suspend
  rescue => err
    $vcloud_log.error("vm=[#{vm.name}], error: #{err}")
  end

  def vm_restart(vm, _options = {})
    vm.restart
  rescue => err
    $vcloud_log.error("vm=[#{vm.name}], error: #{err}")
  end

  def self.display_name(number = 1)
    n_('Cloud Provider (VMware vCloud)', 'Cloud Providers (VMware vCloud)', number)
  end

  def vm_create_snapshot(vm, options = {})
    options[:quiesce] = 'false'
    with_provider_connection do |service|
      service.post_create_snapshot(vm.uid_ems, options)
    end
  end

  def vm_remove_snapshot(vm, options = {})
    vm_remove_all_snapshots(vm, options)
  end

  def vm_remove_all_snapshots(vm, options = {})
    with_provider_connection do |service|
      service.post_remove_all_snapshots(vm.uid_ems)
    end
  end
end
