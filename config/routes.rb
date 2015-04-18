Rails.application.routes.draw do
  devise_scope :user do
    get 'users', :to => 'users/registrations#index'
    get 'users/mass_new', :to => 'users/registrations#mass_new'
    post 'users/mass_create', :to => 'users/registrations#mass_create'
    get 'users/admin_new', :to => 'users/registrations#admin_new'
    post 'users/admin_create', :to => 'users/registrations#admin_create'
    delete 'users/:id/destroy', :to => 'users/registrations#admin_destroy'
    get 'users/non_admins', :to => 'users/registrations#users_index'
    get 'users/admins', :to => 'users/registrations#admins_index'
    devise_for :users, :controllers => { :registrations => "users/registrations" }
    get 'users/:id', :to => 'users/registrations#show'
  end

  namespace "questions" do
    get ':id/without_answers', action: 'show_without_answers', as: 'show_without_answers'
    get 'questions_per_weightage', action: 'questions_per_weightage', as: 'questions_per_weightage'
    post ':id', action: 'update', as: 'update'
  end
  resources :questions 

  namespace "exams" do
    get 'my_exams', action: 'my_exams', as: 'my_exams'
    get 'timezones', action: 'timezones', as: 'timezones'
    post ':id/scheme', action: 'set_scheme', as: 'set_scheme'
    get ':id/scheme', action: 'show_scheme', as: 'show_scheme'
    post ':id/questions', action: 'set_questions', as: 'set_questions'
    get ':id/questions', action: 'select_questions', as: 'select_questions'
    post ':id/colleges', action: 'set_colleges', as: 'set_colleges'
    get ':id/colleges', action: 'select_colleges', as: 'select_colleges'
    get ':id/question_categories', action: 'question_categories', as: 'question_categories'
    post ':id', action: 'update', as: 'update'
  end
  resources :exams

  namespace "answer_sheets" do
    get ':id/review', action: 'review', as: 'review'
    get 'time_up', action: 'time_up', as: 'time_up'
    post ':id/change_ip', action: 'update_ip', as: 'update_ip'
    get 'change_ip', action: 'change_ip', as: 'change_ip'
    post ':id', action: 'update', as: 'update'
  end
  resources :answer_sheets

  namespace "colleges" do
    post ':id', action: 'update', as: 'update'
  end
  resources :colleges

  namespace "question_categories" do
    post ':id', action: 'update', as: 'update'
  end
  resources :question_categories

  resources :programming_tasks

  namespace "programming_exams" do
    get 'my_exams', action: 'my_exams', as: 'my_exams'
    get 'timezones', action: 'timezones', as: 'timezones'
    post ':id/programming_tasks', action: 'set_programming_tasks', as: 'set_programming_tasks'
    get ':id/programming_tasks', action: 'select_programming_tasks', as: 'select_programming_tasks'
    post ':id/colleges', action: 'set_colleges', as: 'set_colleges'
    get ':id/colleges', action: 'select_colleges', as: 'select_colleges'
    post ':id', action: 'update', as: 'update'
  end
  resources :programming_exams

  namespace "programming_answer_sheets" do
    get ':id/review', action: 'review', as: 'review'
    get 'time_up', action: 'time_up', as: 'time_up'
    post ':id/change_ip', action: 'update_ip', as: 'update_ip'
    get 'change_ip', action: 'change_ip', as: 'change_ip'
    get ':id/get_program', action:'get_program', as: 'get_program'
    post ':id/save_program', action: 'save_program', as: 'save_program'
    post ':id/check_program', action: 'check_program', as: 'check_program'
    post ':id/run_program', action: 'run_program', as: 'run_program'
  end
  resources :programming_answer_sheets

  root to: "welcome#welcome"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
