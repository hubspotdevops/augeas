#
# Author:: Craig Tracey (craigtracey@gmail.com)
# Copyright:: Copyright (c) 2012 Craig Tracey
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'augeas'
require 'strscan'

action :execute do

  @new_resource.commands.each do |res_command|
    cmd = augeas_config "cmd" do
      command res_command
      save 0
    end
  end

  $aug.save()
end

