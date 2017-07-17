# frozen_string_literal: true

namespace :pdp do
  namespace :perf do
    desc 'Test performance of checking whether'\
          ' user permission to execute action on random resources'
    task test: :environment do
      Benchmark.bm do |x|
        10.times do
          resource = random_object_of_model Resource
          user = random_object_of_model User
          action_name = random_object_of_model(Action).name
          x.report { check_permission(user, resource, action_name) }
          puts "Resource id: #{resource.id}, user id #{user.id}, action #{action_name}"
        end
      end
    end
  end

  private

  def random_object_of_model(model_class)
    models_no = model_class.send :count
    offset = Random.rand models_no
    model_class.send(:limit, 1).offset(offset).take
  end

  def check_permission(user, resource, action_name)
    ResourcePolicy.new(user, resource).permit? action_name
  end
end
