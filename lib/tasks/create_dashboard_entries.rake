desc "Adding items for dashboard cards"
task :add_dashboard_questions => :environment do
  DashboardQuestion.destroy_all
  DashboardQuestion.create([
                      {
                        :id => 1,
                        :action_item => "",
                        :button_text => "",
                        :description => "",
                        :status => 0,
                        :title => "",
                        :type => 1
                      },
                      {
                        :id => 2,
                        :action_item => "",
                        :button_text => "",
                        :description => "",
                        :status => 0,
                        :title => "",
                        :type => 2
                      }
                     ], :without_protection => true)
end
