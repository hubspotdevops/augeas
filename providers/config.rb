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

COMMANDS = {
  "set" => [ :path, :value ],
  "rm" => [ :path ],
  "clear" => [ :path ]
}

def parse_command(command)

  cmdline = Hash.new

  cmd_params = command.split(/\s+/,2)
  if cmd_params.length == 2
    cmdline['cmd'] = cmd_params[0]
    params = cmd_params[1]
  end

  param_types = COMMANDS[cmdline['cmd']]
  if param_types == nil
    raise "Unsupported augeas command: #{cmd}"
  end

  ss = StringScanner.new(params)
  param_types.each do |type|

    if type == :path
      bracket_count = 0
      single_quote_count = 0
      double_quote_count = 0
      endpos = -1
      in_escape = false

      begin
        c = ss.getch
        if not in_escape
          case c
          when "\\"
            in_escape = true
          when "["
            bracket_count += 1
          when "]"
            bracket_count -= 1
          when "'"
            single_quote_count += 1
          when "\""
            double_quote_count += 1
          end
        else
          in_escape = false
        end

        if c == " " or c == "\t" or ss.eos?
          if bracket_count == 0 and
            single_quote_count % 2 == 0 and
            double_quote_count % 2 == 0
            endpos = ss.pos
            break
          end
        end
      end while ss.eos? == false

      if endpos > 0
        cmdline['path'] = params[0,endpos]
      else
        raise "Could not parse augeas command: #{command}"
      end
    elsif type == :value
      cmdline['value'] = ss.rest
    end
  end
  cmdline
end

def open_augeas()
  Chef::Log.info("Calling open")
  if $aug == nil
    Chef::Log.info("Opening augeas")
    $aug = Augeas::open("/tmp")
  end
end

action :execute do

  cmdline = parse_command(@new_resource.command)

  open_augeas()
  case cmdline['cmd']
  when "set"
    $aug.set(cmdline['path'], cmdline['value'])
  end

  if @new_resource.save
    $aug.save()
  end
end

