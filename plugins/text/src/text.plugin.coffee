# Export Plugin
module.exports = (BasePlugin) ->
	# Define Plugin
	class TextPlugin extends BasePlugin
		# Plugin name
		name: 'text'

		# Plugin config
		config:
			semanticWrap: true

		# Get the text
		getText: (opts) ->
			# Prepare
			{source,store} = opts
			key = source or ''
			key = 'store.'+key.replace(/[#\{\(\n]/g,'').trim()

			# Fetch the value
			try
				result = eval(key) ? source
			catch err
				result = source

			# Return
			result

		# Populate text
		# next(err,result)
		populateText: (opts,next) ->
			# Prepare
			me = @
			docpad = @docpad
			balUtil = require('bal-util')
			{source,templateData,file} = opts

			# Prepare the replace element
			replaceElementCallback = (outerHTML, elementName, attributes, innerHTML, replaceElementCompleteCallback) ->
				# Grab the value
				result = me.getText({source:innerHTML,store:templateData})

				# Grab the type/render attribute
				format = balUtil.getAttribute(attributes,'format') or balUtil.getAttribute(attributes,'render') or balUtil.getAttribute(attributes,'type') or ''
				# ^ render and type are deprecated

				# Wrap it in a special element
				if me.config.semanticWrap
					formatAttr = if format then ' format="'+format+'"' else ''
					propertyValue = innerHTML.replace('"','\\"')
					if innerHTML is result
						# no replace was done from the store, must be inline
						sourceAttr   = ' about="inline"'
						propertyAttr = ''
						formatAttr = ''
					else if /^document\./.test(innerHTML) is true
						sourceAttr   = ' about="'+templateData.document.url+'"'
						propertyAttr = ' property="'+propertyValue.replace(/^document\./,'')+'"'
					else
						sourceAttr   = ' about="templateData"'
						propertyAttr = ' property="'+propertyValue+'"'
					result = "<span#{sourceAttr}#{propertyAttr}#{formatAttr}>#{result}</span>"
					
				# Prepare replace element tasks
				replaceElementTasks = new balUtil.Group (err) ->
					return replaceElementCompleteCallback(err,result)

				# Facilate deep elements
				replaceElementTasks.push (complete) ->
					# Populate the valuecd  te
					me.populateText {file,templateData,source:result}, (err,populateTextResult) ->
						return complete(err)  if err
						result = populateTextResult
						return complete()

				# If we have a type attribute, then perform a render
				if format
					# Render the text as a document with extensions
					replaceElementTasks.push (complete) ->
						# Generate filename
						filename = 'docpad-text-plugin'
						parentExtension = file.get('extensionRendered')
						parentFilename = file.get('filename')
						if format.indexOf('.') is -1 and (parentExtension or parentFilename)
							filename += '.'+(parentExtension or parentFilename)
						filename += '.'+format

						# Prepare options
						renderTextOpts = {
							filename: filename
							templateData: templateData
							renderSingleExtensions: true
							actions: ['renderExtensions']
						}

						# Render text with options and apply the result
						docpad.renderText result, renderTextOpts, (err,renderTextResult,document) ->
							return complete(err)  if err
							result = renderTextResult
							return complete()

				# Run replace element tasks
				replaceElementTasks.sync()

			# Render the elements
			balUtil.replaceElementAsync(source, 't(?:ext)?', replaceElementCallback, next)

			# Chain
			@

		# Render the document
		renderDocument: (opts,next) ->
			# Prepare
			me = @
			{templateData,file} = opts

			# Only run on text content
			if file.isText()
				# Populate the file content
				me.populateText {file,templateData,source:opts.content}, (err,result) ->
					return next(err)  if err
					opts.content = result
					return next()
			else
				return next()