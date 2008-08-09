# Copyright (c) 2008 Todd Willey <todd@rubidine.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_uniqueness_of_tuple *columns
        options = columns.last.is_a?(Hash) ? attrs.pop.symbolize_keys : {}

        send(validation_method(options[:on] || :save)) do |record|
          q = [columns.collect{|x| "#{x.to_s}=?"}.join(' AND ')]
          q += columns.collect{|x| record.send(x)}
          unless record.new_record?
            pk = record.class.primary_key
            q[0] << " AND #{pk} != ?"
            q << record.send(pk)
          end
          if self.find(:first, :conditions => q)
            record.errors.add(options[:error_key] || 'tuple', 'is not unique')
          end
        end

        # play nicely with the reflect_on_validations plugin
        # (degrades cleanly)
        write_inheritable_array "validations", [ActiveRecord::Reflection::MacroReflection.new(:validates_uniqueness_of_tuple, columns, options, self)]
      end
    end
  end
end
