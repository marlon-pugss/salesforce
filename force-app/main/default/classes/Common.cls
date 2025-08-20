public class Common {
     
    //General
    public static INTEGER REQUEST_TIMEOUT		          = 3000;
    public static String SALESFORCE_SOURCE		          = 'SALESFORCE';
    public static String RECORD_NOT_CREATED		          = 'Record not created properly';
    public static String RECORD_NOT_RETURNED	          = 'Record not returned properly';
    public static String SUCCESSFULLY_EXECUTED	          = 'Executado com sucesso';
    public static String EXECUTED_WITH_ERROR	          = 'Executado com erro';
    public static String PRODUCT_NOT_FOUND		          = 'Produto não encontrado';
    public static String CONTRACT_NOT_FOUND		          = 'Contrato não encontrado';
    public static String BATCH_SIZE_NOT_EXPECTED          = 'Não é possível invocar este batch com mais de um registro por vez!';
    public static String NOVO						      = 'Novo';
    public static String FECHADO					      = 'Fechado';
    public static String MERGED						      = 'Merged';
    public static String HIGH						      = 'High';
    public static String MEDIUM						      = 'Medium';
    public static String SUCCESS		 		          = 'Success';
    public static String ERROR			 		          = 'Error';
    public static String PENDING				          = 'Pending';
    public static String FAILED					          = 'Failed';
    public static String SPAM					          = 'Spam';
    public static String WAITING					      = 'Waiting';
    public static String ENDED						      = 'Ended';
    public static String SENT							  = 'Enviado';
    public static String INACTIVE						  = 'Inactive';
    public static String ACTIVE						      = 'Active';
    public static String DISQUALIFIED				      = 'Desqualificado';
    public static String DISABLED					      = 'Desabilitada';
    public static String ANSWERED 			 			  = 'Respondido';
    public static String CANCELED 			 			  = 'canceled';
    public static String CONFIRMED 			 			  = 'confirmed';
    public static String RECOVERY						  = 'Recuperação';
    public static String FLUENCY_EMAIL_DOMAIN	          = 'fluencyacademy.io';
    public static String CX_SERVICE_EMAIL		          = 'atendimentocx@fluencyacademy.io';
    public static String ZERO_NUMBER_STRING			      = '0';
    public static String FLUENCY				          = 'Fluency';
    public static String AWARI				              = 'Awari';
    public static String EXPIRED				          = 'Expirado';
	public static String INTENSIVO				          = 'INTENSIVO';
	public static String PAYMENTLESS			          = 'Paymentless';
    public static String STANDARD_PRICEBOOK_ID		      = '01s8b000002RCgZAAW';
    public static String READ_TIMED_OUT				      = 'Read timed out';
    public static String QUERY_OPERATOR_EQUAL	          = ' = ';
    public static String QUERY_OPERATOR_NOT_EQUAL	      = ' != ';
    public static Set<String> ENDED_AND_INACTIVE		  = new Set<STRING>{ENDED, INACTIVE};
    public static Set<Integer> SERVICE_POSITIVE_STATUS    = new Set<Integer>{200, 201, 202};
	public static Map<String, String> OFFER_TYPES		  = new Map<String, String>{'MAIN' => 'Regular', 'RECURRING' => 'Recorrente'};
	public static Map<Integer, String> ALERT_STATUS_ICONS = new Map<Integer, String>{1 => ':warning-pulsing:', 2 => ':alert-red:'};

    //User
    public static String USER_ID_SF_EA					= '0058b00000GHmas';
    public static String USER_ID_SERVICE_CX				= '0058b00000HM93XAAT';
    public static String ALL_DAYS_WORK_SCHEDULE			= 'Sunday; Monday; Tuesday; Wednesday; Thursday; Friday; Saturday';
    public static List<String> OWNER_ID_NOT_MAPPED_CASE = new List<String>{'00G8b000003MiBwEAK','00G8b000003MiC6EAK','00G8b000003MiCQEA0'};
    
    //Profile
    public static String PROFILE_ADMIN_ID				= '00e8b000002Mxu8AAC';
    public static String ADMIN_PROFILES_STRING			= '\'Administrador do sistema\', \'System Administrator\'';
    public static String PROFILES_TO_ROTATE_LEAD_STRING = '\'Administrador do sistema\', \'System Administrator\', \'Gerente - Atendimento\'';
    public static Set<String> PROFILES_TO_ROTATE_LEAD	= new Set<String>{'Administrador do sistema', 'System Administrator', 'Gerente - Atendimento'};
    public static Set<String> ADMIN_PROFILES			= new Set<String>{'Administrador do sistema', 'System Administrator'};
    
    //Account
    public static String ACCOUNT_RT_ID_BUSINESS			  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaEmpresarial').getRecordTypeId();
    public static String ACCOUNT_RT_ID_PERSON_ACCOUNT	  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    public static String ACCOUNT_JOURNEY_ACTIVATION		  = 'Activation';
    public static String ACCOUNT_JOURNEY_CANCELED		  = 'Canceled';
    public static String ACCOUNT_JOURNEY_CHARGING		  = 'Charging';
    public static String ACCOUNT_JOURNEY_LOST_OPPORTUNITY = 'Lost Opportunity';
    public static String ACCOUNT_JOURNEY_RETENTION		  = 'Retention';
    public static String ACCOUNT_JOURNEY_SALES			  = 'Sales';
    public static String ACCOUNT_JOURNEY_STUDENT		  = 'Student';
    public static String ACCOUNT_JOURNEY_SUPPORT		  = 'Support';
    
    //Opportunity
    public static String OPP_STAGENAME_PENDING						= 'Pendente';
    public static String OPP_STAGENAME_FIRST_CONTACT				= 'Primeiro contato';
    public static String OPP_STAGENAME_CLOSED_WIN					= 'Fechado/Ganho';
    public static String OPP_STAGENAME_CLOSED_LOST					= 'Fechado/Perdido';
    public static String OPP_STAGENAME_DUPLICATED					= 'Oportunidade duplicada';
    public static String OPP_STAGENAMES_CLOSED_STRING				= '\'Fechado/Ganho\', \'Fechado/Perdido\', \'Oportunidade duplicada\'';
    public static String OPP_STAGENAMES_CLOSED_WIN_AND_DUPLICATED	= '\'Fechado/Ganho\', \'Oportunidade duplicada\'';
    public static Set<String> OPP_STAGENAMES_CLOSED					= new Set<String>{OPP_STAGENAME_CLOSED_WIN, OPP_STAGENAME_CLOSED_LOST, OPP_STAGENAME_DUPLICATED};
    public static Set<String> OPP_STAGENAMES_CLOSED_LOST			= new Set<String>{OPP_STAGENAME_CLOSED_LOST, OPP_STAGENAME_DUPLICATED};
    public static String OPP_LOSS_REASON_EXPIRED					= 'Expirada';
    public static String OPP_LOSS_REASON_CLOSING_AUTOMATICALLY		= 'Fechamento automático';
    public static String OPP_LOSS_REASON_EXPIREDS					= '\'Expirada\', \'Fechamento automático\'';
    public static Set<String> OPP_LOSS_REASONS_TO_NOT_JOURNEY_LOST	= new Set<String>{OPP_LOSS_REASON_EXPIRED, OPP_LOSS_REASON_CLOSING_AUTOMATICALLY};
    public static String OPP_JOURNEY_LOST							= 'Perdida';
    public static String OPP_JOURNEY_WAITING_LIST					= 'Lista de Espera';
    public static String OPP_JOURNEY_DOWNSELL						= 'Downsell';
    public static String OPP_OMNI_EVENT_CREATED						= 'OPPORTUNITY_CREATED';
    public static String OPP_OMNI_EVENT_STAGE_UPDATED				= 'OPPORTUNITY_STAGE_UPDATED';
    public static String OPP_OMNI_EVENT_OWNER_ROTATED				= 'OPPORTUNITY_OWNER_ROTATED';
    public static String OPP_EVENT_LOST_TO_BUZZLEAD					= 'LOST_OPPORTUNITY_TO_BUZZLEAD';
    public static String OPP_MODALITY_CHARGED						= 'Charged';
    public static String OPP_RT_ID_PAYMENTLESS						= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId();
    public static String OPP_RT_ID_INSIDESALES						= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('InsideSales').getRecordTypeId();
    public static String OPP_RT_ID_B2B								= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId();
    public static String OPP_RT_ID_RECYCLE							= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Recycle').getRecordTypeId();
    public static String OPP_RT_ID_RECOVERY							= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Recovery').getRecordTypeId();
    public static String OPP_RT_NAME_RECYCLE						= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Recycle').getDeveloperName();
    public static Set<String> OPP_RT_ID_INSIDESALES_AND_RECYCLE	    = new Set<String>{OPP_RT_ID_INSIDESALES, OPP_RT_ID_RECYCLE};
    
    //Lead
    public static String LEAD_BRAND_MGM								   = 'MgM';
    public static String LEAD_LEADSOURCE_REFERRAL_PROGRAM			   = 'Referral Program';
    public static String LEAD_LEADSOURCE_WHATSAPP_ORG			       = 'Whatsapp - ORG';
    public static String LEAD_STATUS_QUALIFIED						   = 'Qualificado';
    public static String LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE			   = 'Não apto a distribuir';
    public static String LEAD_STATUS_DUPLICATE			 			   = 'Duplicado';
    public static String LEAD_STATUS_PROSPECTING		 			   = 'Prospecção';
    public static String LEAD_STATUSES_CLOSED_STRING                   = '\'Não apto a distribuir\', \'Qualificado\', \'Desqualificado\', \'Duplicado\'';
    public static String LEAD_SUBSTATUS_OPEN_OPPORTUNITY               = 'Oportunidade Aberta';
    public static String LEAD_SUBSTATUS_OPEN_LEAD                      = 'Lead Aberto';
    public static String LEAD_SUBSTATUS_UNANSWERED                     = 'Não Respondido';
    public static String LEAD_ASSOCIATION_TO_CAMPAIGN_WAITING		   = 'Waiting association';
    public static String LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED	   = 'Associated';
    public static String LEAD_ASSOCIATION_TO_CAMPAIGN_NOT_ASSOCIATED   = 'Not associated'; 
    public static String LEAD_EVENT_ASSOCIATE_LEAD                     = 'ASSOCIATE_LEAD'; 
    public static String LEAD_EVENT_LEADS_TO_CONVERT                   = 'LEADS_TO_CONVERT';
    public static String LEAD_EVENT_LEADS_TO_ROTATE                    = 'LEADS_TO_ROTATE';
    public static String LEAD_EVENT_DUPLICATE_LEAD_TO_BUZZLEAD		   = 'DUPLICATE_LEAD_TO_BUZZLEAD';
    public static String LEAD_SOURCE_MGM_BUZZLEAD					   = 'MgM - Buzzlead';
    public static String LEAD_RT_ID_STUDENTS						   = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Alunos').getRecordTypeId();
    public static String LEAD_RT_ID_B2B								   = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId();
    public static String LEAD_RT_ID_RECYCLE							   = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Recycle').getRecordTypeId();
    public static String LEAD_RT_NAME_RECYCLE						   = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Recycle').getDeveloperName();
    public static Set<String> LEAD_STATUSES_CLOSED	                   = new Set<String>{LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE, LEAD_STATUS_QUALIFIED, DISQUALIFIED, LEAD_STATUS_DUPLICATE};
    public static Set<String> LEAD_STATUSES_NOT_CLOSED_SET			   = new Set<String>{LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE, LEAD_STATUS_QUALIFIED, DISQUALIFIED, LEAD_STATUS_DUPLICATE, EXPIRED};
    public static Set<String> LEAD_BRANDS_TO_NOT_CONVERT_FROM_CONTRACT = new Set<String>{LEAD_BRAND_MGM};

    //Contract
    public static String CONTRACT_STATUS_ACTIVE	                       	            = 'Ativo';
    public static String CONTRACT_STATUS_DRAFT 	                       	            = 'Rascunho';
    public static String CONTRACT_STATUS_CANCELED	                   	            = 'Cancelado';
    public static String CONTRACT_STATUS_INACTIVE	                   	            = 'Inativo';
    public static String CONTRACT_STATUS_FINISHED 	                   	            = 'Finalizado';
    public static String CONTRACT_RT_ID_B2B		                       	            = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId();
    public static String CONTRACT_RT_ID_B2C              	           	            = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();
    public static String CONTRACT_RT_NAME_B2C                  	       	            = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('B2C').getDeveloperName();
    public static String CONTRACT_CANCELLATION_REASON_ORIGIN 	       	            = 'Cancelado na Origem';
    public static String CONTRACT_CANCELLATION_REASON_SOLICITATION     	            = 'Solicitação';
    public static String CONTRACT_CANCELLATION_REASON_INCOMPLIANT	   	            = 'Inadimplência';
    public static String CONTRACT_CANCELLATION_REASON_PARENT_CANCELED	            = 'Contrato Pai cancelado';
    public static String CONTRACT_CANCELLATION_REASON_SINGLE_INSTALLMENT            = 'Parcela única cancelada, status: ';
    public static String CONTRACT_CANCELLATION_REASON_AUTO_NON_COMPLIANT_PROCESS    = 'Fluxo automático de Inadimplência';
    public static String CONTRACT_CREATED								            = 'CONTRACT_CREATED';
    public static String CONTRACT_UPDATED						   	   	            = 'CONTRACT_UPDATED';
    public static String CONTRACT_EVENT_BUZZLEAD_CONFIRMATION	   	   	            = 'CONTRACT_BUZZLEAD_CONFIRMATION';
    public static List<String> CONTRACT_STATUSES_CANCELED_AND_FINISHED_AND_INACTIVE	= new LIST<String>{CONTRACT_STATUS_CANCELED, CONTRACT_STATUS_FINISHED, CONTRACT_STATUS_INACTIVE};
    
    //Case
    public static String CASE_QUEUE_FOR_DISTRIBUTION_FINANCIAL_RETENTION_BRASIL = 'RETENCAO_FINANCEIRA_BRASIL';
    public static String CASE_QUEUE_FOR_DISTRIBUTION_SALES_RETENTION            = 'SALES_RETENTION';
    public static String CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM				= 'TIME_DE_COBRANÇA';
    public static String CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM_BRASIL		= 'TIME_DE_COBRANÇA_BRASIL'; //Brasil acrescentado pós TEAM e mesma coisa em Time de Cobrança
    public static String CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM_LATAM		    = 'TIME_DE_COBRANÇA_LATAM'; //LATAM e ROTW criadas em 04/09, não existiam anteriormente
    public static String CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM_ROTW		    = 'TIME_DE_COBRANÇA_ROTW'; //LATAM e ROTW criadas em 04/09, não existiam anteriormente
    public static String CASE_QUEUE_FOR_DISTRIBUTION_RECOVERY_TEAM              = 'TIME_DE_RECUPERAÇÃO';
    public static String CASE_QUEUE_FOR_DISTRIBUTION_NON_COMPLIANCE_TEAM        = 'TIME_INADIMPLENCIA';
    public static String CASE_STATUS_WAITING_STUDENT                            = 'AguardandoAluno';
    public static String CASE_STATUS_WAITING_AGENT                              = 'AguardandoAgente';
    public static String CASE_STATUS_CHAT_TRANSCRIPT                            = 'Transcrição de chat';
    public static String CASE_CLOSING_REASON_OPENED_BY_EMAIL                    = 'Aberto por email';
    public static String CASE_ORIGIN_CHAT                                       = 'Chat';
    public static String CASE_ORIGIN_SALES                                      = 'Sales';
    public static String CASE_CLOSED_BY_CHAT                                    = 'Fechado por chat';
    public static String CASE_FORWARDED_TO_RECOVERY_TEAM                        = 'Direcionado para Recuperação';
    public static String CASE_COMPLETED_PAYMENT                                 = 'Pagamento concluído';
    public static String CASE_SUBJECT_SUBSCRIPTION_CANCELLATION_AT_ORIGIN		= 'Cancelamento de assinatura na Origem da compra';
    public static String CASE_TYPE_CONTRACT_CANCELED                            = 'Contrato Cancelado'; 
    public static String CASE_TYPE_CHARGE                                       = 'Cobrança';
    public static String CASE_TYPE_RETENTION                                    = 'Retenção';
    public static String CASE_TYPE_SUPPORT                                      = 'Suporte';
    public static String CASE_TYPE_CHAT                                         = 'Chat';
    public static String CASE_STATUSES_CLOSED_STRING							= '\'Fechado\', \'Merged\'';
    public static String CASE_EVENT_ROTATE_CASE                            		= 'ROTATE_CASE';
    public static List<String> CASE_STATUSES_CLOSED								= new List<String>{FECHADO, MERGED};
    public static List<String> CASE_TYPE_RETENTION_AND_SUPPORT			        = new List<String>{CASE_TYPE_RETENTION, CASE_TYPE_SUPPORT};
    public static List<String> CASE_CLOSING_REASONS_SPAM_AND_OPENED_BY_EMAIL    = new List<String>{SPAM, CASE_CLOSING_REASON_OPENED_BY_EMAIL};
    public static String CASE_RT_ID_BILLING										= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    public static String CASE_RT_ID_DEFAULT										= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Padrao').getRecordTypeId();
        
    //QueueDistribution__c
    public static String QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY = 'Fila não possui usuários/nenhum usuário na escala';
    public static String QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED			 = 'Capacidade máxima atingida para todos usuários';
    public static String QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING						 = 'Distribuindo';  
    public static String QUEUE_DISTRIBUTION_RT_ID_LEAD								 = Schema.SObjectType.QueueDistribution__c.getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();  
    public static String QUEUE_DISTRIBUTION_RT_ID_CASE								 = Schema.SObjectType.QueueDistribution__c.getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();
    public static String QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY						 = Schema.SObjectType.QueueDistribution__c.getRecordTypeInfosByDeveloperName().get('Opportunity').getRecordTypeId();
    
    //PaymentOrder__c
    public static String ORDER_STATUS_DELAYED					= 'DELAYED';
    public static String ORDER_STATUS_CANCELED					= 'CANCELED';
    public static String ORDER_STATUS_PENDING					= 'PENDING';
    public static String ORDER_STATUS_REFUNDED					= 'REFUNDED';
    public static String ORDER_STATUS_REFUSED					= 'REFUSED';
    public static String ORDER_STATUS_PAID						= 'PAID';
    public static String ORDER_STATUS_DISPUTE					= 'DISPUTE';
    public static String ORDER_STATUS_CHARGEBACK				= 'CHARGEBACK';
    public static String ORDER_STATUS_EXPIRED					= 'EXPIRED';
    public static String ORDER_STATUSES_DELAYED_STRING	        = '\'DELAYED\', \'PENDING\', \'EXPIRED\', \'REFUSED\', \'CANCELED\'';
    public static String ORDER_STATUS_COMPLIANCY_STRING			= '\'DELAYED\', \'PENDING\', \'EXPIRED\', \'REFUSED\', \'DISPUTE\'';
    public static Set<String> ORDER_STATUSES_CREATE_TRANSACTION = new Set<String>{'PAID'};
    public static List<String> ORDER_STATUSES_DELAYED			= new List<String>{ORDER_STATUS_DELAYED, ORDER_STATUS_PENDING, ORDER_STATUS_EXPIRED, ORDER_STATUS_REFUSED, ORDER_STATUS_CANCELED};
    public static List<String> ORDER_STATUSES_DISPUTE			= new List<String>{ORDER_STATUS_DISPUTE, ORDER_STATUS_CHARGEBACK};
    public static List<String> ORDER_STATUSES_TO_CANCEL			= new List<String>{ORDER_STATUS_CHARGEBACK, ORDER_STATUS_REFUNDED, ORDER_STATUS_CANCELED};
    public static List<String> ORDER_STATUS_WITH_HIGH_PRIORITY	= new List<String>{ORDER_STATUS_DELAYED, ORDER_STATUS_PENDING, ORDER_STATUS_EXPIRED, ORDER_STATUS_DISPUTE};
    public static List<String> ORDER_STATUS_COMPLIANCY			= new List<String>{ORDER_STATUS_DELAYED, ORDER_STATUS_PENDING, ORDER_STATUS_EXPIRED, ORDER_STATUS_REFUSED, ORDER_STATUS_DISPUTE};
    
    //Transaction
    public static String TRANSACTION_EVENT_PAYMENT_REFUND                                        = 'PAYMENT_REFUND';
    public static String TRANSACTION_STATUS_REFUND_REQUESTED                                     = 'REFUND REQUESTED';
    public static List<String> TRANSACTION_STATUSES_CHARGEBACK_DISPUTE_REFUNDED_REFUND_REQUESTED = new List<String>{ORDER_STATUS_CHARGEBACK, ORDER_STATUS_DISPUTE, ORDER_STATUS_REFUNDED, TRANSACTION_STATUS_REFUND_REQUESTED};
    
    //ProdutoContratado__c
    public static String CONTRACTED_PRODUCT_RT_ID_LICENSE = Schema.SObjectType.ProdutoContratado__c.getRecordTypeInfosByDeveloperName().get('License').getRecordTypeId();
    public static String CONTRACTED_PRODUCT_RT_ID_DEFAULT = Schema.SObjectType.ProdutoContratado__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
	
    //FluencyNotification__c
    public static String FLUENCY_NOTIFICATION_RT_ID_CALLOUT	 = Schema.SObjectType.FluencyNotification__c.getRecordTypeInfosByDeveloperName().get('Callout').getRecordTypeId();
    public static String FLUENCY_NOTIFICATION_RT_ID_INTERNAL = Schema.SObjectType.FluencyNotification__c.getRecordTypeInfosByDeveloperName().get('Internal').getRecordTypeId();
    
    //Loss__c
    public static String LOSS_RT_ID_OPPORTUNITY = Schema.SObjectType.Loss__c.getRecordTypeInfosByDeveloperName().get('Opportunity').getRecordTypeId();
    
    //MessagingSession
    public static String MESSAGING_SESSION_CHANNEL_ID_WHATSWAPP_IS		  = '0MjV2000000sCtpKAE';
    public static String MESSAGING_SESSION_EVENT_GET_CONVERSATION_ENTRIES = 'GET_CONVERSATION_ENTRIES';
    
    //UserServicePresence
    public static String USER_SERVICE_PRESENCE_ID_AVAILABLE = '0N58b000000fzGcCAI';
    public static String USER_SERVICE_PRESENCE_ID_MOBILE	= '0N5V200000000fxKAA';
    public static Set<String> USER_SERVICE_PRESENCE_IDS_AVAILABLE_MOBILE = new Set<String>{USER_SERVICE_PRESENCE_ID_AVAILABLE, USER_SERVICE_PRESENCE_ID_MOBILE};
    
    //HTML Methods
    public static String GET   = 'GET';
    public static String PUT   = 'PUT';
    public static String POST  = 'POST';
    public static String PATCH = 'PATCH';
    
}