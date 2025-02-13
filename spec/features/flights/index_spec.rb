require 'rails_helper'

RSpec.describe 'The Flights Index Page' do
  before(:each) do
    @airline_1 = Airline.create!(name: "Frontier")
    @airline_2 = Airline.create!(name: "Southwest")

    @flight_1 = Flight.create!(number: 222, date: "02/04/22", departure_city: "Denver", arrival_city: "Chicago", airline_id: @airline_1.id)
    @flight_2 = Flight.create!(number: 223, date: "02/06/22", departure_city: "Chicago", arrival_city: "New-York", airline_id: @airline_1.id)
    @flight_3 = Flight.create!(number: 386, date: "04/12/22", departure_city: "Denver", arrival_city: "Las Vegas", airline_id: @airline_2.id)

    @passenger_1 = Passenger.create!(name: "Dawson", age: 24)
    @passenger_2 = Passenger.create!(name: "Tim", age: 42)
    @passenger_3 = Passenger.create!(name: "Sally", age: 39)
    @passenger_4 = Passenger.create!(name: "Matt", age: 20)
    @passenger_5 = Passenger.create!(name: "Jennifer", age: 53)
    @passenger_6 = Passenger.create!(name: "Murphy", age: 12)

    @fp_1 = FlightPassenger.create!(flight_id: @flight_1.id, passenger_id: @passenger_1.id)
    @fp_2 = FlightPassenger.create!(flight_id: @flight_1.id, passenger_id: @passenger_2.id)
    @fp_3 = FlightPassenger.create!(flight_id: @flight_1.id, passenger_id: @passenger_3.id)
    @fp_4 = FlightPassenger.create!(flight_id: @flight_2.id, passenger_id: @passenger_4.id)
    @fp_5 = FlightPassenger.create!(flight_id: @flight_2.id, passenger_id: @passenger_5.id)
    @fp_6 = FlightPassenger.create!(flight_id: @flight_3.id, passenger_id: @passenger_6.id)

    visit "/flights"
  end
  describe 'User Story 1' do
    it "a visitor of the flights index page sees a list of all flight numbers, and next to each flight number shows the name of the Airline of that flight" do
      expect(page).to have_content("Flight #222 - Airline: Frontier")
      expect(page).to have_content("Flight #223 - Airline: Frontier")
      expect(page).to have_content("Flight #386 - Airline: Southwest")
    end
    
    it "shows under each flight number the names of all that flight's passengers" do
      within("#passengers_for_flight-#{@flight_1.id}") {
        expect(page).to have_content("Dawson")
        expect(page).to have_content("Tim")
        expect(page).to have_content("Sally")
      }
      within("#passengers_for_flight-#{@flight_2.id}") {
        expect(page).to have_content("Matt")
        expect(page).to have_content("Jennifer")
      }
      within("#passengers_for_flight-#{@flight_3.id}") {
        expect(page).to have_content("Murphy")
      }
    end
  end

  describe 'User Story 2' do
    it 'shows the visitor a button to remove that passenger from that flight, for each passenger' do
      within("#passenger-#{@passenger_1.id}") {
        expect(page).to have_button("Remove Dawson")
      }
      within("#passenger-#{@passenger_2.id}") {
        expect(page).to have_button("Remove Tim")
      }
      within("#passenger-#{@passenger_3.id}") {
        expect(page).to have_button("Remove Sally")
      }
      within("#passenger-#{@passenger_4.id}") {
        expect(page).to have_button("Remove Matt")
      }
      within("#passenger-#{@passenger_5.id}") {
        expect(page).to have_button("Remove Jennifer")
      }
      within("#passenger-#{@passenger_6.id}") {
        expect(page).to have_button("Remove Murphy")
      }
    end

    it 'redirects back to the index page after this button is clicked, they no longer see that passenger listed under that flight,
    but they still see the passenger listed under the other flights they were assigned to' do
      
      @fp_6 = FlightPassenger.create!(flight_id: @flight_2.id, passenger_id: @passenger_1.id)
      visit "/flights"
    
      within("#passengers_for_flight-#{@flight_1.id}") {
        expect(page).to have_content("Dawson")
        expect(page).to have_content("Tim")
        expect(page).to have_content("Sally")
      }
      within("#passengers_for_flight-#{@flight_2.id}") {
        expect(page).to have_content("Matt")
        expect(page).to have_content("Jennifer")
        expect(page).to have_content("Dawson")
      }

      within("#passengers_for_flight-#{@flight_2.id}") {
        within("#passenger-#{@passenger_1.id}") {
          click_button "Remove Dawson"
        }
      }

      expect(current_path).to eq(flights_path)

      within("#passengers_for_flight-#{@flight_2.id}") {
        expect(page).to have_content("Matt")
        expect(page).to have_content("Jennifer")
      }

      within("#passengers_for_flight-#{@flight_1.id}") {
        expect(page).to have_content("Dawson")
        expect(page).to have_content("Tim")
        expect(page).to have_content("Sally")
      }

    end
  end
end