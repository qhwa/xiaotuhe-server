json.success @share.persisted?
json.partial! 'shares/share', share: @share
