# WORKING AS OF 10/24/16!

#------------------Edit these variables---------------------#
#Access token generated by an account admin
$auth_token = ''

#If your instance is utah.instructure.com, this is just 'utah'
$school_domain = ''

#The full path to the CSV mapping file
$mapping_file_path = ""

#No need to edit this
$api_base_url = "https://#{$school_domain}.instructure.com/api/v1/"

#----------------------------------------------------------#
#  Don't edit from here unless you know what you are doing #
#----------------------------------------------------------#
#Required gems - INSTALL THESE BEFORE STARTING
require 'rubygems'
require 'json'
require 'typhoeus'
require 'csv'

#------------------Read File Data------------------------#
# - Pulls information from the CSV File
#---------------------------------------------------------#

def read_file_data
  #open mapping file
  CSV.foreach($mapping_file_path, headers: true) do |row|

    #Check that headers are correct
    if row['user_id'].nil? || row['email'].nil?
      raise 'Valid CSV headers not found (Expecting user_id,email)'
    else
        add_channel(row['user_id'],row['email'])
    end
  end
end


#-------------------Add Comm Channel-------------------------#
# - Updates a user email address
#---------------------------------------------------------#
def add_channel(user_id, email)

  response = Typhoeus.post(

            "#{$api_base_url}/users/sis_user_id:#{user_id}/communication_channels",
            headers: {
              :authorization => 'Bearer ' + $auth_token},
            body: {
              communication_channel: {
                :address => email,
                :type => "email",
              },
              :skip_confirmation => true

            }
        )
    #parse JSON data to save in readable array
    data = JSON.parse(response.body)
    puts "add channel data \n#{data}"
    if response.code == 200
      #puts "Successfully updated user #{user_id}'s email address (#{response.code})"
    else
      puts "There was an issue processing user #{user_id}'s email (#{response.code})"
    end

    update_email(user_id,email)
end


#-------------------Update Email Address-------------------------#
# - Updates a user email address
#---------------------------------------------------------#
def update_email(user_id, email)

  # if $user_sis_id
  #   user_id = "sis_user_id:#{user_id}"
  # end
  response = Typhoeus.put(

            "#{$api_base_url}/users/sis_user_id:#{user_id}",
            headers: {
              :authorization => 'Bearer ' + $auth_token,
              'Content-Type'=> "application/x-www-form-urlencoded" #this might break
             },
            body: {
              user: {
                :email => email
              }
            }
        )
    #parse JSON data to save in readable array
    data = JSON.parse(response.body)
    puts "edit user data: \n#{data}"

    if response.code == 200
      puts "Successfully updated user #{user_id}'s email address (#{response.code})"
    else
      puts "There was an issue processing user #{user_id}'s email (#{response.code})"
    end
end

read_file_data
