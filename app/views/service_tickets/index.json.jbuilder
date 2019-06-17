json.array!(@service_tickets) do |service_ticket|
  json.extract! service_ticket, :id
  json.url service_ticket_url(service_ticket, format: :json)
end
