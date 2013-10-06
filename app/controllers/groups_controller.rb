class GroupsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @groups = current_user.groups
  end
end
