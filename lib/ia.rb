# encoding: utf-8
require_relative 'question'
require_relative 'table'
require_relative 'lang'

module IA

	def process_texts	
		q=Question.new
		texts.each do |t|
			s=Set.new [name, "Ninguna es correcta"]
			neighbors.each { |n| s.add n[:concept].name } 
			a=s.to_a
				
			if s.count>3 then
				@num+=1
				q.init
				q.set_choice
				q.name="#{name}-#{@num.to_s}a1-desc"
				q.text=LANG::text('a1-desc',t,lang)
				q.good=name
				q.bads << "Ninguna es correcta"
				q.bads << a[2]
				q.bads << a[3]
				q.write_to_file @file
			end
			
			s.delete(name)
			a=s.to_a
			
			if s.count>3 then
				@num+=1
				q.init
				q.set_choice
				q.name="#{name}-#{@num.to_s}a2-desc"
				q.text=LANG::text('a2-desc',t,lang)
				q.good="Ninguna es correcta"
				q.bads << a[1]
				q.bads << a[2]
				q.bads << a[3]
				q.write_to_file @file
			end
			
			@num+=1
			q.init
			q.set_boolean
			q.name="#{name}-#{@num.to_s}a3-desc"
			q.text="Definición de #{name}\:<br/> \"#{t}\"<br/>"
			q.good="TRUE"
			q.write_to_file @file

			if neighbors.count>0 then
				@num+=1
				q.init
				q.set_boolean
				q.name="#{name}-#{@num.to_s}a4-desc"
				q.text="Definición de #{neighbors[0][:concept].name}\:<br/> \"#{t}\"<br/>"
				q.good="FALSE"
				q.write_to_file @file
			end
			
			@num+=1
			q.init
			q.set_short
			q.name="#{name}-#{@num.to_s}a5-desc"
			q.text="Definición de [#{ hiden_name }]\:<br/> \"#{t}\"<br/>"
			q.shorts << name
			q.write_to_file @file
		end
	end

	def process_table_match(pTable, pList1, pList2)
		return if pTable.fields.count<2
		if pTable.fields.count>1 then
			process_table_match2fields(pTable, pList1, pList2, 0, 1)
		elsif pTable.fields.count>2 then
			process_table_match2fields(pTable, pList1, pList2, 0, 2)
			process_table_match2fields(pTable, pList1, pList2, 1, 2)
		elsif pTable.fields.count>3 then
			process_table_match2fields(pTable, pList1, pList2, 0, 3)
			process_table_match2fields(pTable, pList1, pList2, 1, 3)
			process_table_match2fields(pTable, pList1, pList2, 2, 3)
		end
	end
	
	def process_table_match2fields(pTable, pList1, pList2, pIndex1, pIndex2)
		q=Question.new
		if pList1.count>3 then
			@num+=1
			q.init
			q.set_match
			q.name="#{name}-#{@num.to_s}b1-match-#{pTable.name}"
			q.text="En relación al concepto #{name}, asocia cada #{pTable.fields[pIndex1].capitalize} con su #{pTable.fields[pIndex2].capitalize}<br/>."
			q.matching << [ pList1[0][:data][pIndex1], pList1[0][:data][pIndex2] ]
			q.matching << [ pList1[1][:data][pIndex1], pList1[1][:data][pIndex2] ]
			q.matching << [ pList1[2][:data][pIndex1], pList1[2][:data][pIndex2] ]
			q.matching << [ pList1[3][:data][pIndex1], pList1[3][:data][pIndex2] ]
			q.write_to_file @file
		elsif pList1.count==3 and pList2.count>0 then
			s=Set.new
			pList1.each { |i| s.add( i[:data][pIndex1]+"<=>"+i[:data][pIndex2] ) }
			s.add( pList2[0][:data][pIndex1]+"<=>"+pList2[0][:data][pIndex2] ) 
			a=s.to_a

			if s.count>3 then
				@num+=1
				q.init
				q.set_match
				q.name="#{name}-#{@num.to_s}b2-match-#{pTable.name}"
				q.text="En relación al concepto #{name}, asocia cada #{pTable.fields[pIndex1].capitalize} con su #{pTable.fields[pIndex2].capitalize}<br/>."
				q.matching << [ pList1[0][:data][pIndex1], pList1[0][:data][pIndex2] ]
				q.matching << [ pList1[1][:data][pIndex1], pList1[1][:data][pIndex2] ]
				q.matching << [ pList1[2][:data][pIndex1], pList1[2][:data][pIndex2] ]
				q.matching << [ pList2[0][:data][pIndex1], "ERROR" ]
				q.write_to_file @file
			end			
		end
	end
	
	def process_tableXfields(pTable, pRow, pList)
		return if pTable.fields.count<2
		if pTable.fields.count>1 then
			process_table2fields(pTable, pRow, pList, 0, 1)
		elsif pTable.fields.count>2 then
			process_table2fields(pTable, pRow, pList, 0, 2)
			process_table2fields(pTable, pRow, pList, 1, 2)
		elsif pTable.fields.count>3 then
			process_table2fields(pTable, pRow, pList, 0, 3)
			process_table2fields(pTable, pRow, pList, 1, 3)
			process_table2fields(pTable, pRow, pList, 2, 3)
		end
	end

	def process_table2fields(lTable, lRow, pList, pCol1, pCol2)
		q=Question.new	

		#create gift questions	
		s=Set.new [ lRow[:data][0] , "Ninguna es correcta" ]
		pList.each { |i| s.add( i[:data][0] ) }
		a=s.to_a
		
		if s.count>3 then		
			@num+=1
			q.init
			q.name="#{name}-#{@num.to_s}c1-#{lTable.name}"
			q.text="Concepto #{name}:<br/>#{lTable.fields[0].capitalize}\: [...]<br/>#{lTable.fields[1].capitalize}: \"#{lRow[:data][1]}\"<br/>Completa con la opción correcta."
			q.good=lRow[:data][0]
			q.bads << "Ninguna es correcta"
			q.bads << a[2]
			q.bads << a[3]
			q.write_to_file @file		
		end
				
		s=Set.new [ lRow[:data][0], "Ninguna es correcta" ]
		pList.each { |i| s.add( i[:data][0] ) }
		a=s.to_a

		if s.count>4 then
			@num+=1
			q.init
			q.name="#{name}-#{@num.to_s}c2-#{lTable.name}"
			q.text="Concepto #{name}:<br/>#{lTable.fields[0].capitalize}\: [...]<br/>#{lTable.fields[1].capitalize}: \"#{lRow[:data][1]}\"<br/>Completa con la opción correcta."
			q.good="Ninguna es correcta"
			q.bads << a[2]
			q.bads << a[3]
			q.bads << a[4]
			q.write_to_file @file
		end

		s=Set.new [ lRow[:data][1], "Ninguna es correcta" ]
		pList.each { |i| s.add( i[:data][1] ) }
		a=s.to_a

		if s.count>3 then			
			@num+=1
			q.init
			q.name="#{name}-#{@num.to_s}c3-#{lTable.name}"
			q.text="Concepto #{name}:<br/>#{lTable.fields[0].capitalize}\: \"#{lRow[:data][0]}\"<br/>#{lTable.fields[1].capitalize}\: [...]<br/>Completa con la opción correcta."
			q.good=a[0]
			q.bads << "Ninguna es correcta"
			q.bads << a[2]
			q.bads << a[3]
			q.write_to_file @file		
		end
		
		s=Set.new [ lRow[:data][1], "Ninguna es correcta" ]
		pList.each { |i| s.add( i[:data][1] ) }
		a=s.to_a

		if s.count>4 then			
			@num+=1
			q.init
			q.name="#{name}-#{@num.to_s}c4-#{lTable.name}"
			q.text="Concepto #{name}:<br/>#{lTable.fields[0].capitalize}\: \"#{lRow[:data][0]}\"<br/>#{lTable.fields[1].capitalize}\: [...]<br/>Completa con la opción correcta."
			q.good="Ninguna es correcta"
			q.bads << a[2]
			q.bads << a[3]
			q.bads << a[4]
			q.write_to_file @file
		end

		@num+=1
		q.init
		q.set_boolean
		q.name="#{name}-#{@num.to_s}c5-#{lTable.name}"
		q.text="Concepto #{name}:<br/>La asociación siguiente es correcta\:<br/>#{lTable.fields[0].capitalize}\: \"#{lRow[:data][0]}\"<br/>#{lTable.fields[1].capitalize}\: #{lRow[:data][1]}<br/>."
		q.good="TRUE"
		q.write_to_file @file

		s=Set.new [ lRow[:data][1] ]
		pList.each { |i| s.add( i[:data][1] ) }
		a=s.to_a

		if s.count>1 then		
			@num+=1
			q.init
			q.set_boolean
			q.name="#{name}-#{@num.to_s}c6-#{lTable.name}"
			q.text="Concepto #{name}:<br/>La asociación siguiente es correcta\:<br/>#{lTable.fields[0].capitalize}\: \"#{lRow[:data][0]}\"<br/>#{lTable.fields[1].capitalize}\: \"#{a[1]}\"<br/>."
			q.good="FALSE"
			q.write_to_file @file
		end
		
		s=Set.new [ lRow[:data][0] ]
		pList.each { |i| s.add( i[:data][0] ) }
		a=s.to_a

		if s.count>1 then
			@num+=1
			q.init
			q.set_boolean
			q.name="#{name}-#{@num.to_s}c7-#{lTable.name}"
			q.text="Concepto #{name}:<br/>La asociación siguiente es correcta\:<br/>#{lTable.fields[0].capitalize}\: \"#{a[1]}\"<br/>#{lTable.fields[1].capitalize}\: \"#{lRow[:data][1]}\"<br/>."
			q.good="FALSE"
			q.write_to_file @file
		end
	end
		
	def reorder_list_with_row(pList, pRow)
		#evaluate every row of the list2
		pList.each do |lRow|
			if lRow[:id]==pRow[:id] then
				lRow[:weight]=-300
			else
				val=0
				s=pRow[:data].count
				s.times do |i|
					val=val+calculate_nearness_between_texts(pRow[:data][i],lRow[:data][i])
				end
				val=val/s
				lRow[:weight]=val
			end
		end
		pList.sort! { |a,b| a[:weight] <=> b[:weight] }
		pList.reverse!
	end
	
	def calculate_nearness_between_texts(pText1, pText2)
		words=pText1.split(" ")
		count=0
		words.each do |w|
			count +=1 if pText2.include? w
		end
		return (count*100/words.count)
	end	

	def not_equals(a,b,c,d)
		return (a!=b && a!=c && a!=d && b!=c && b!=d && c!=d)
	end

	def calculate_nearness_to_concept(pConcept)
		liMax1=@data[:context].count
		liMax2=@data[:tags].count
		liMax3=@data[:tables].count

		lfAlike1=0.0
		lfAlike2=0.0
		lfAlike3=0.0
		
		@data[:context].each { |i| lfAlike1+=1.0 if !pConcept.context.index(i).nil? }	
		@data[:tags].each { |i| lfAlike2+=1.0 if !pConcept.tags.index(i).nil? }
		@data[:tables].each { |i| lfAlike3+=1.0 if !pConcept.tables.index(i).nil? }	

		lfAlike =(lfAlike1*@weights[0]+lfAlike2*@weights[1]+lfAlike3*@weights[2])
		liMax = (liMax1*@weights[0]+liMax2*@weights[1]+liMax3*@weights[2]) 
		return ( lfAlike*100.0/ liMax )
	end

end
