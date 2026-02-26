require 'rails_helper'
require 'rake'

RSpec.describe 'downloads soft-delete and restore rake tasks' do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  before do
    %w[
      downloads:soft_delete:one
      downloads:soft_delete:by_user
      downloads:soft_delete:all
      downloads:restore:one
      downloads:restore:by_user
      downloads:restore:all
    ].each { |task_name| Rake::Task[task_name].reenable }
  end

  it 'calls soft delete by uuid service' do
    expect(Downloads::SoftDeleteService).to receive(:by_uuid!).with('uuid-1').and_return(1)

    expect { Rake::Task['downloads:soft_delete:one'].invoke('uuid-1') }
      .to output(/Soft-deleted downloads: 1/).to_stdout
  end

  it 'calls soft delete by user service' do
    expect(Downloads::SoftDeleteService).to receive(:by_user!).with('42').and_return(3)

    expect { Rake::Task['downloads:soft_delete:by_user'].invoke('42') }
      .to output(/Soft-deleted downloads: 3/).to_stdout
  end

  it 'calls soft delete all service' do
    expect(Downloads::SoftDeleteService).to receive(:all!).and_return(5)

    expect { Rake::Task['downloads:soft_delete:all'].invoke }
      .to output(/Soft-deleted downloads: 5/).to_stdout
  end

  it 'calls restore by uuid service' do
    expect(Downloads::RestoreService).to receive(:by_uuid!).with('uuid-2').and_return(1)

    expect { Rake::Task['downloads:restore:one'].invoke('uuid-2') }
      .to output(/Restored downloads: 1/).to_stdout
  end

  it 'calls restore by user service' do
    expect(Downloads::RestoreService).to receive(:by_user!).with('99').and_return(2)

    expect { Rake::Task['downloads:restore:by_user'].invoke('99') }
      .to output(/Restored downloads: 2/).to_stdout
  end

  it 'calls restore all service' do
    expect(Downloads::RestoreService).to receive(:all!).and_return(7)

    expect { Rake::Task['downloads:restore:all'].invoke }
      .to output(/Restored downloads: 7/).to_stdout
  end
end
