class InvoiceMailer < ActionMailer::Base
  default from: "sales@weaverbarns.com"
  layout 'mailer'
end
