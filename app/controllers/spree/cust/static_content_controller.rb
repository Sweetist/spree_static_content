module Spree
  module Cust
    class StaticContentController < Spree::Cust::CustomerHomeController
      rescue_from ActiveRecord::RecordNotFound, with: :render_404
      before_action :ensure_user_has_accounts
      before_action :load_vendor, only: :show

      helper 'spree/products'
      layout :determine_layout

      def show
        @customer = current_customer
        if @vendor.present?
          @page = @vendor.pages.visible.find_by_slug!(request.path)
          @pages_footer = @vendor.pages.footer_links
          render :show
        else
          flash[:error] = 'We were unable to find the page you requested.'
          redirect_to root_path
        end
      end

      private

      def load_vendor
        if request.host == ENV['DEFAULT_URL_HOST']
          flash[:error] = 'We were unable to find the page you requested.'
          redirect_to root_path
        else
          @vendor = current_customer.vendors.find_by_custom_domain(request.host)
        end
      end

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
