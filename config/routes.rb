Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "users/registrations" }

  get 'questions/questions_per_weightage', to: 'questions#questions_per_weightage'
  post 'questions/:id', to: 'questions#update'
  resources :questions 

  post 'exams/:id/scheme', to: 'exams#set_scheme'
  get 'exams/:id/scheme', to: 'exams#show_scheme'
  post 'exams/:id/questions', to: 'exams#set_questions'
  get 'exams/:id/questions', to: 'exams#select_questions'
  post 'exams/:id/colleges', to: 'exams#set_colleges'
  get 'exams/:id/colleges', to: 'exams#select_colleges'
  post 'exams/:id', to: 'exams#update'
  resources :exams

  get 'answer_sheets/time_up', to: 'answer_sheets#time_up'
  post 'answer_sheets/:id', to: 'answer_sheets#update'
  resources :answer_sheets

  post 'colleges/:id', to: 'colleges#update'
  resources :colleges

  get 'my_exams', to: 'exams#my_exams'
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
