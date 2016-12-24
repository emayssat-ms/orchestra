_OPENSSL_MK_VERSION=0.99.0

SSL_BASE64_ENCODING?=enabled
SSL_CYPHER_TYPE?=aes-256-cbc
SSL_ENVIRONMENT?=
SSL_DECRYPTED_FILE?=
SSL_LABEL?=[openssl] #
SSL_OPTIONS?=
SSL_ENCRYPTED_FILE?=$(SSL_DECRYPTED_FILE).ssl
SSL_PASSPHRASE?=
SSL_PASSPHRASE_FILE?=
SSL_PASSPHRASE_SOURCE?=

ifeq($(SSL_BASE64_ENCODING),enabled)
	__SSL_OPTIONS+= -a
endif

ifneq($(SSL_PASSPHRASE),)
	__SSL_OPTIONS+= -k $(SSL_PASSPHRASE)
endif

OPENSSL=$(SSL_ENVIRONMENT) openssl $(__SSL_OPTIONS) $(SSL_OPTIONS)

#----------------------------------------------------------------------
# INTERFACE
#

_view_makefile_macros :: _ssl_view_makefile_macros
_ssl_view_makefile_macros ::

_view_makefile_targets :: _ssl_makefile_targets
_ssl_makefile_targets:
	@echo "OPENSSL ($(_OPENSSL_MK_VERSION)) targets:"
	@echo "    _ssl_encrypt_file                  - Encrypt a file with SSL"
	@echo "    _ssl_decrypt_file                  - Decrypt an encrypted file"
	@echo

_view_makefile_variables :: _ssl_view_makefile_variables
_ssl_view_makefile_variables:
	@echo "OPENSSL ($(_OPENSSL_MK_VERSION)) variables:"
	@echo "    SSL_BASE64_ENCODING=$(SSL_BASE64_ENCODING)"
	@echo "    SSL_DECRYPTED_FILE=$(SSL_DECRYPTED_FILE)"
	@echo "    SSL_LABEL=$(SSL_LABEL)"
	@echo "    SSL_OPTIONS=$(SSL_OPTIONS)"
	@echo "    SSL_ENCRYPTED_FILE=$(SSL_ENCRYPTED_FILE)"
	@echo "    SSL_PASSPHRASE=$(SSL_PASSPHRASE)"
	@#echo "    SSL_PASSPHRASE_FILE=$(SSL_PASSPHRASE_FILE)"
	@#echo "    SSL_PASSPHRASE_SOURCE=$(SSL_PASSPHRASE_SOURCE)"
	@echo


#----------------------------------------------------------------------
# 
#

_ssl_encrypt_file:
	@$(INFO) "$(SSL_LABEL)Encrypt file '$(SSL_DECRYPTED_FILE)' ..."; $(NORMAL)
	$(OPENSSL) -e -in $(SSL_DECRYPTED_FILE) -out $(SSL_ENCRYPTED_FILE) 
	
_ssl_decrypt_file:
	@$(INFO) "$(SSL_LABEL)Decrypt file '$(SSL_ENCRYPTED_FILE)' ..."; $(NORMAL)
	$(OPENSSL) -d -in $(SSL_ENCRYPTED_FILE) -out $(SSL_DECRYPTED_FILE) 
