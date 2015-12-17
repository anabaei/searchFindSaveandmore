class ProductsController < ApplicationController
   require 'Savon'

  def index
  end
 
  def show
    @pros = Product.all
  end


  def find
  	  @@finalname= []
  	  @@finalsku= []
  	  n= 0  

    if params[:search_sku].blank? 

         if params[:search_name].blank? 
                
			    else 
			    	
                 
			    	@search_name = params[:search_name]
			       client = Savon.client(wsdl: "http://services.dev.bcldb.com:25211/ProductService/ProductPort?wsdl") 
			       results_name = %q(
			        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prod="http://productservice.services.bcldb.com">
			       <soapenv:Header/>
			         <soapenv:Body>
			             <prod:baseProductsByNameRequest>
			             <prod:name>)+@search_name.to_s+%q(</prod:name>
			              <prod:firstRecord>1</prod:firstRecord>
			               <prod:numberOfRecords>1000</prod:numberOfRecords>
			              <prod:searchLocation>ANY</prod:searchLocation>
			              </prod:baseProductsByNameRequest>
			           </soapenv:Body>
			        </soapenv:Envelope>)
			       response_name = client.call(:get_base_products_by_name, xml: results_name)
			       @response_name =  response_name.to_array(:base_products_by_name_response,:base_product)
                    
                     @response_name.each do |j|  
		   		        @@finalname[n] = j[:product_name] 
		   	            @@finalsku[n] =	j[:sku] 
		   	            n=n+1
		            end

			          respond_to do |format|
                          #    #format.html {render "products/index" }
                            format.js { render :action => 'ajaxcallname.js.erb', lcoals: { response_name: @response_name } }
                       end

			    end
    else
       
       @search_sku = params[:search_sku]
       client_sku = Savon.client(wsdl: "http://services.dev.bcldb.com:25211/ProductService/ProductPort?wsdl") 
       results_sku = %q(
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prod="http://productservice.services.bcldb.com">
           <soapenv:Header/>
              <soapenv:Body>
                <prod:productBySKURequest>
                   <prod:sku>)+@search_sku.to_s+%q(</prod:sku>
                </prod:productBySKURequest>
             </soapenv:Body>
           </soapenv:Envelope>
            )
       response_sku = client_sku.call(:get_product_by_sku, xml: results_sku)
      
           if response_sku.success?
             data = response_sku.to_array(:product_by_sku_response, :product).first
             data_longName= response_sku.to_array(:product_by_sku_response, :product, :upc).first
             data_country = response_sku.to_array(:product_by_sku_response, :product, :origin, :country).first
             data_comment = response_sku.to_array(:product_by_sku_response, :product, :comments, :comment).first
             data_container = response_sku.to_array(:product_by_sku_response, :product, :case_configuration, :package_information, :container).first
             data_type =  response_sku.to_array(:product_by_sku_response, :product, :vendors, :vendor)[3]
             data_manager =  response_sku.to_array(:product_by_sku_response, :product, :category_manager).first
             
               
	           @name = data[:product_name]
	           @@finalname[n]=  @name 
  	           @@finalsku[n]=   @search_sku
	           @brand = data[:brand]
	           @long_name = data_longName[:long_name] 
	           @country = data_country[:code] 
	           @description = data_comment[:description] 
	           @size =  data_container[:size]
	           @weight = data_container[:weight]

		             if data_manager.nil?
		               @manager_name = "No Name"
		               @manager_code =  "No Code"
		              else 
		               @manager_name = data_manager[:manager_name]
		               @manager_code = data_manager[:manager_code]
		             end

			        respond_to do |format|
			                          #    #format.html {render "products/index" }
			           format.js { render  :action => 'ajaxcallsku.js.erb', lcoals: {
	                   name:  @name,
	                   brand: @brand,
	                   country: @country,
	                   description: @description,
	                   size: @size,
	                   weight: @weight, 
	                   manager_name: @manager_name
			            } }
			          end
            end 
    #    render "products/index"
        end
     end


     def create
        sav = 0
       cont =  @@finalsku.length
       i = 0

           while	i < cont
                pro = Product.new
         		pro.sku = @@finalsku[i]
         		pro.name = @@finalname[i]
                 i += 1
             if pro.save
                sav = 1
             end  
           end

           if sav
        	render 'thankyou'
        	else
        	
        	end 

    end


   def destroy
       @product = Product.find(params[:id])
       @product.destroy
 
        redirect_to products_show_path
   end


 end


