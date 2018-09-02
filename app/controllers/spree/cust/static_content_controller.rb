module Spree
  module Cust
    class StaticContentController < Spree::Cust::CustomerHomeController
      rescue_from ActiveRecord::RecordNotFound, with: :render_404
      before_action :ensure_user_has_accounts

      helper 'spree/products'
      layout :determine_layout

      def show
        @customer = current_customer
        @vendors = @customer.vendors.order('name ASC')
        @vendor = current_vendor || @vendors.first
        @page = @vendor.pages.visible.find_by_slug!(request.path)
        @pages_footer = @vendor.pages.footer_links
      end

      private

      def determine_layout
        return @page.layout if @page && @page.layout.present? && !@page.render_layout_as_partial?
        'frontend-customer'
      end

      def accurate_title
        @page ? (@page.meta_title.present? ? @page.meta_title : @page.title) : nil
      end
    end
  end
end
