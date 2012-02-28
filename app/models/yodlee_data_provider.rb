class YodleeDataProvider < ActiveRecord::Base
  validates :content_service_id, :uniqueness => true
  scope :banks, where(:provider_type => "bank")
  scope :credits, where(:provider_type => "credits")

  has_many :creditors, :foreign_key => "content_service_id", :primary_key => "content_service_id"

  def self.populate!(container_name = "bank")
    @halberd_us = Halberd::Us.new
    @halberd_us.connect!
    @interface = @halberd_us.get_interface
    if container_name
      service_list = @interface.get_service_list(container_name)
      document = service_list.doc

      elements = document.xpath("//getContentServicesByContainerType2Return/elements")
    else
     service_list = @interface.get_all_content_service_list
     document = service_list.doc
     elements = document.xpath("//getContentServicesByContainerTypeReturn/table/value/elements")
    end

    yodlee_data_providers = elements.map do |element|
      if ydp = YodleeDataProvider.find_by_content_service_id(element.at_xpath(".//contentServiceId").content)
        ydp.update_attributes({:content_service_id => element.at_xpath(".//contentServiceId").content,
                               :organization_display_name => element.at_xpath(".//organizationDisplayName").content,
                               :content_service_display_name => element.at_xpath(".//contentServiceDisplayName").content,
                               :site_display_name => element.at_xpath(".//siteDisplayName").content,
                               :provider_type => element.at_xpath(".//containerInfo/containerName").content,
                               :mfa_type => element.at_xpath(".//mfaType") && element.at_xpath(".//mfaType").content});
        nil
      else
        new({:content_service_id => element.at_xpath(".//contentServiceId").content,
             :organization_display_name => element.at_xpath(".//organizationDisplayName").content,
             :content_service_display_name => element.at_xpath(".//contentServiceDisplayName").content,
             :site_display_name => element.at_xpath(".//siteDisplayName").content,
             :provider_type => element.at_xpath(".//containerInfo/containerName").content,
             :mfa_type => element.at_xpath(".//mfaType") && element.at_xpath(".//mfaType").content})
      end
    end.compact
   
    import yodlee_data_providers, :validate => true
  end

  def refresh_login_form!
    @halberd_us ||= begin
      us = Halberd::Us.new
      us.connect!
      us
    end

    interface = @halberd_us.get_interface
    resp = interface.get_login_form(self.content_service_id)
    self.login_form = resp.to_xml
    save
  end

  def get_login_form
    if login_form.blank?
      refresh_login_form!
    end
    hash = Nori.parse(login_form)
    hash[:envelope][:body][:get_login_form_for_content_service_response][:get_login_form_for_content_service_return][:component_list][:elements]
  end
end
