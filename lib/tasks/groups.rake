# frozen_string_literal: true

namespace :groups do
  desc 'Generates groups in DB for testing hierarchical groups performance'
  task generate: :environment do
    top_level_groups = (ENV['TOP_LEVEL_GROUPS'] || 10).to_i
    children_number = (ENV['CHILDREN_NUMBER'] || 5).to_i
    group_tree_height = (ENV['GROUP_TREE_HEIGHT'] || 5).to_i
    fail_if_invalid_arguments(top_level_groups, children_number, group_tree_height)
    generate_groups(top_level_groups, children_number, group_tree_height)
  end

  desc 'Benchmark retrieving all parents for a given group'
  task benchmark: :environment do
    n = (ENV['N'] || 10).to_i
    raise 'N must be grater than 0' if n <= 0

    groups = Group.all
    results = {}
    groups.each { |g| results[g.name] = [] }
    n.times do
      groups.each do |g|
        results[g.name] << (Benchmark.measure { g.all_parents }).real
      end
    end

    worst_time = results.values.flatten.max
    puts format('Worst time %.6f s', worst_time)
    puts 'Finished'
  end

  private

  def generate_groups(top_level_groups, children_number, tree_height)
    name_prefix = SecureRandom.urlsafe_base64 4
    1.upto top_level_groups do |group_no|
      generate_group_with_children(name_prefix + group_no.to_s, children_number, tree_height, nil)
    end
  end

  def generate_group_with_children(g_name, children_number, tree_height, parent = nil)
    group = Group.create(name: g_name, parent_group: parent)
    puts "Generate Group #{g_name} with parent #{parent.try :name}"
    return if tree_height > 1

    1.upto children_number do |child_number|
      group_name = g_name.to_s + child_number.to_s
      generate_group_with_children(group_name, children_number, tree_height - 1, group)
    end
  end

  def fail_if_invalid_arguments(top_level_groups, children_number, group_tree_height)
    msg = ''
    msg << "TOP_LEVEL_GROUPS must be greater than 0\n" if top_level_groups <= 0
    msg << "CHILDREN_NUMBER must be greater than 0\n" if children_number <= 0
    msg << "GROUP_TREE_HEIGHT must be greater than 0\n" if group_tree_height <= 0
    raise msg unless msg == ''
  end
end
