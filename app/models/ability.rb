class Ability
  include CanCan::Ability

  def initialize(user)
    if user != nil
        user ||= User.new
        if user.role[:role_name] == "admin"
            can :manage, :site
        else
            can :give, :exam
        end
    end
  end

end
