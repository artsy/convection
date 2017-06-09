module Admin
  class AssetsController < Admin::ApplicationController
    def show
      asset = Asset.find(params[:id])
      original = asset.original_image
      render locals: {
        page: Administrate::Page::Show.new(dashboard, requested_resource),
        original: original
      }
    end
  end
end
