___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Algolia Search Insights",
  "categories": [
    "ANALYTICS", 
    "SESSION_RECORDING", 
    "CONVERSIONS"
  ],
  "brand": {
    "id": "github.com_ayruz-data-marketing",
    "displayName": "Ayruz-data-marketing"
  },
  "description": "Algolia Search Insights helps you report click, conversions and view metrics",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "appId",
    "displayName": "Application ID",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "apiKey",
    "displayName": "API Key",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "eventType",
    "displayName": "Event Type",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "click",
        "displayValue": "Click"
      },
      {
        "value": "conversion",
        "displayValue": "Conversion"
      },
      {
        "value": "view",
        "displayValue": "View"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "click"
  },
  {
    "type": "TEXT",
    "name": "index",
    "displayName": "Index",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "Name of the targeted index. \u003cbr/\u003e\nFormat: same as the index name used by the search engine."
  },
  {
    "type": "CHECKBOX",
    "name": "overrideData",
    "checkboxText": "Override server event data",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "eventName",
    "displayName": "Event Name",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "overrideData",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "help": "Uses Event name from data layer by default"
  },
  {
    "type": "TEXT",
    "name": "userToken",
    "displayName": "User Identifier",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "overrideData",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "help": "Uses randomly generated user tokens by default"
  },
  {
    "type": "GROUP",
    "name": "group1",
    "displayName": "Additional Data",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "RADIO",
        "name": "dataType",
        "displayName": "",
        "radioItems": [
          {
            "value": "none",
            "displayValue": "None"
          },
          {
            "value": "objectIDs",
            "displayValue": "Object IDs"
          },
          {
            "value": "filters",
            "displayValue": "Filters"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "none"
      },
      {
        "type": "GROUP",
        "name": "obj",
        "displayName": "",
        "groupStyle": "NO_ZIPPY",
        "subParams": [
          {
            "type": "TEXT",
            "name": "queryID",
            "displayName": "Query ID",
            "simpleValueType": true
          },
          {
            "type": "SIMPLE_TABLE",
            "name": "objectIDs",
            "displayName": "Objects",
            "simpleTableColumns": [
              {
                "defaultValue": "",
                "displayName": "Object ID",
                "name": "objectID",
                "type": "TEXT",
                "valueHint": "",
                "valueValidators": []
              },
              {
                "defaultValue": "",
                "displayName": "Position",
                "name": "position",
                "type": "TEXT"
              }
            ],
            "valueValidators": [],
            "help": "An array of index objectID. Limited to 20 objects. \u003cbr\u003e Position of the click in the list of Algolia search results.  This field is required if a queryID is provided. One position must be provided for each objectID."
          }
        ],
        "enablingConditions": [
          {
            "paramName": "dataType",
            "paramValue": "objectIDs",
            "type": "EQUALS"
          }
        ]
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "filters",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Attribute",
            "name": "attribute",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT"
          }
        ],
        "enablingConditions": [
          {
            "paramName": "dataType",
            "paramValue": "filters",
            "type": "EQUALS"
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const getAllEventData = require("getAllEventData");
const JSON = require("JSON");
const sendHttpRequest = require("sendHttpRequest");
const getTimestamp = require("getTimestamp");
const log = require("logToConsole");
const makeTableMap = require("makeTableMap");
const getCookieValues = require("getCookieValues");
const setCookie = require("setCookie");
const generateRandom = require("generateRandom");
const makeString = require("makeString");
const makeInteger = require("makeInteger");
const encodeUri = require('encodeUri');
const getContainerVersion = require('getContainerVersion');
const containerVersion = getContainerVersion();
const isDebug = containerVersion.debugMode;
const getRequestHeader = require('getRequestHeader');
const traceId = getRequestHeader('trace-id');

const eventData = getAllEventData();

const MAX_USER_TOKEN = 100000;

const postHeaders = {
	"Content-Type": "application/json",
	"X-Algolia-Application-Id": data.appId,
    "X-Algolia-API-Key": data.apiKey
};

const urlToCall = "https://insights.algolia.io/1/events";

const postBodyData = getPostBody();
log(data);

const postBody = JSON.stringify(postBodyData);

callWidget(urlToCall, 0);

function callWidget(widgetUrl, redirectLvl) {
	if (redirectLvl > 5) {
		log("Invalid Redirect Loop");
		data.gtmOnFailure();
		return;
	}

    if (isDebug) {
        log(JSON.stringify({
            'Name': 'JSON Request',
            'Type': 'Request',
            'TraceId': traceId,
            'EventType': data.eventType,
            'RequestUrl': urlToCall,
            'RequestBody': postBodyData,
        }));
    }

	sendHttpRequest(
		widgetUrl,
		(statusCode, headers, body) => {
            if (isDebug) {
                log(JSON.stringify({
                    'Name': 'JSON Request',
                    'Type': 'Response',
                    'TraceId': traceId,
                    'ResponseStatusCode': statusCode,
                    'ResponseHeaders': headers,
                    'ResponseBody': body,
                }));
            }

			if (statusCode >= 200 && statusCode < 300) {
				data.gtmOnSuccess();
			} else if (statusCode >= 300 && statusCode < 400) {
				callWidget(headers.location, redirectLvl + 1);
			} else {
				data.gtmOnFailure();
			}
		},
		{ headers: postHeaders, method: "POST", timeout: 3000 },
		postBody
	);
}

function getPostBody() {
    if(data.dataType === "objectIDs"){
        let obj = getObjectIDs();
        return {
            events: [{
                eventType: data.eventType,
                eventName: data.eventName || eventData.event_name,
                index: data.index,
                userToken: data.userToken || getUserToken(),
                getTimestamp: getTimestamp(),
                objectIDs: obj.objectIDs,
                queryID: data.queryID,
                positions: obj.positions
            }]
        };
    } else if(data.dataType === "filters") {
        return {
            events: [{
                eventType: data.eventType,
                eventName: data.eventName || eventData.event_name,
                index: data.index,
                userToken: data.userToken || getUserToken(),
                getTimestamp: getTimestamp(),
                filters: [ getFilters() ]
            }]
        };
    } else {
        return {
            events: [{
                eventType: data.eventType,
                eventName: data.eventName || eventData.event_name,
                index: data.index,
                userToken: data.userToken || getUserToken(),
                getTimestamp: getTimestamp(),
            }]
        };
    }
}

function getUserToken() {
	let userToken = makeString(getCookieValues("_algolia_id")[0] || getTimestamp() + '_' + generateRandom(0, MAX_USER_TOKEN));


	setCookie("_algolia_id", userToken, {
		"max-age": 3600 * 24 * 365 * 2,
		domain: "auto",
		path: "/",
		httpOnly: true,
		secure: true,
	});

	return userToken;
}

function getFilters() {
    const filters = data.filters;
    let encodedFilters = [];

    for (let f in filters) {
        const facet = encodeUri(filters[f].attribute) + ":" + encodeUri(filters[f].attribute);

        encodedFilters.push(facet);
    }

    return encodedFilters;
}

function getObjectIDs() {
    const objects = data.objectIDs;
    let objectIDs = [];
    let positions = [];

    for (let obj in objects) {
        objectIDs.push(objects[obj].objectID);
        positions.push(makeInteger(objects[obj].position));
    }

    return {
        objectIDs: objectIDs,
        positions: positions
    };
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "_algolia_id"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_algolia_id"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "headerWhitelist",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "trace-id"
                  }
                ]
              }
            ]
          }
        },
        {
          "key": "headersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_container_data",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 6/15/2022, 7:31:37 PM


