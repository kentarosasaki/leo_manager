%%====================================================================
%%
%% Leo Manager
%%
%% Copyright (c) 2012-2014 Rakuten, Inc.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------
%% LeoFS Manager - Constant/Macro/Record
%%
%% -------------------------------------------------------------------
-author('yosuke hara').
-include_lib("eunit/include/eunit.hrl").

%% constants
-define(SHUTDOWN_WAITING_TIME, 2000).
-define(MAX_RESTART,              5).
-define(MAX_TIME,                60).

-ifdef(TEST).
-define(DEF_TIMEOUT,           1000). %% 1sec
-define(DEF_MONITOR_INTERVAL,  3000). %% 3sec
-else.
-define(DEF_TIMEOUT,         120000). %% 120sec
-define(DEF_MONITOR_INTERVAL, 20000). %%  20sec
-endif.

-define(SYSTEM_CONF_FILE,  "conf/leofs.conf").


%% manager-related tables
-define(TBL_STORAGE_NODES,  'leo_storage_nodes').
-define(TBL_GATEWAY_NODES,  'leo_gateway_nodes').
-define(TBL_SYSTEM_CONF,    'leo_system_conf').
-define(TBL_REBALANCE_INFO, 'leo_rebalance_info').
-define(TBL_HISTORIES,      'leo_histories').
-define(TBL_AVAILABLE_CMDS, 'leo_available_commands').

%% server-type
-define(SERVER_TYPE_STORAGE, "S").
-define(SERVER_TYPE_GATEWAY, "G").


%% command-related
-define(COMMAND_ERROR,     "Command Error").
-define(COMMAND_DELIMITER, " \r\n").

-define(OK,           "OK\r\n").
-define(ERROR,        "ERROR\r\n").
-define(CRLF,         "\r\n").
-define(SPACE,        " ").
-define(SEPARATOR,    " | ").
-define(STORED,       "STORED\r\n").
-define(NOT_STORED,   "NOT_STORED\r\n").
-define(DELETED,      "DELETED\r\n").
-define(NOT_FOUND,    "NOT FOUND\r\n").
-define(SERVER_ERROR, "SERVER_ERROR").
-define(BYE,          "BYE\r\n").

%% Common Commands
-define(CMD_HELP,    "help").
-define(CMD_QUIT,    "quit").
-define(CMD_VERSION, "version").
-define(CMD_STATUS,  "status").

%% For S3-API
-define(CMD_CREATE_USER,      "create-user").
-define(CMD_UPDATE_USER_ROLE, "update-user-role").
-define(CMD_UPDATE_USER_PW,   "update-user-password").
-define(CMD_DELETE_USER,      "delete-user").
-define(CMD_GET_USERS,        "get-users").
-define(CMD_ADD_ENDPOINT,     "add-endpoint").
-define(CMD_SET_ENDPOINT,     "set-endpoint").
-define(CMD_DEL_ENDPOINT,     "delete-endpoint").
-define(CMD_GET_ENDPOINTS,    "get-endpoints").
-define(CMD_ADD_BUCKET,       "add-bucket").
-define(CMD_GET_BUCKETS,      "get-buckets").
-define(CMD_GET_BUCKET_BY_ACCESS_KEY, "get-bucket").
-define(CMD_DELETE_BUCKET,            "delete-bucket").
-define(CMD_CHANGE_BUCKET_OWNER,      "chown-bucket").
-define(CMD_UPDATE_ACL,               "update-acl").

%% For Storage
-define(CMD_ATTACH,    "attach").
-define(CMD_DETACH,    "detach").
-define(CMD_SUSPEND,   "suspend").
-define(CMD_RESUME,    "resume").
-define(CMD_START,     "start").
-define(CMD_REBALANCE, "rebalance").
-define(CMD_COMPACT,   "compact").
-define(CMD_DU,        "du").
-define(CMD_WHEREIS,   "whereis").

%% For Gateway
-define(CMD_PURGE,           "purge").
-define(CMD_REMOVE,          "remove").
-define(CMD_BACKUP_MNESIA,   "backup-mnesia").
-define(CMD_RESTORE_MNESIA,  "restore-mnesia").
-define(CMD_UPDATE_MANAGERS, "update-managers").

%% For Maintenance
-define(CMD_RECOVER,   "recover").
-define(CMD_HISTORY,   "history").
-define(CMD_DUMP_RING, "dump-ring").

%% For MDC-Replication
-define(CMD_JOIN_CLUSTER,   "join-cluster").
-define(CMD_REMOVE_CLUSTER, "remove-cluster").

-define(LOGIN,      "login").
-define(AUTHORIZED, <<"_authorized_\r\n">>).
-define(USER_ID,    <<"_user_id_\r\n">>).
-define(PASSWORD,   <<"_password_\r\n">>).

-define(COMMANDS, [{?CMD_HELP,      "help"},
                   {?CMD_QUIT,      "quit"},
                   {?CMD_VERSION,   "version"},
                   {?CMD_STATUS,    "status [${storage-node}|${gateway-node}]"},
                   {?CMD_HISTORY,   "history"},
                   {?CMD_DUMP_RING, "dump-ring ${manager-node}|${storage-node}|${gateway-node}"},
                   %% for Cluster
                   {?CMD_WHEREIS,   "whereis ${path}"},
                   {?CMD_RECOVER,   lists:append(
                                      ["recover file ${path}", ?CRLF,
                                       "recover node ${storage-node}", ?CRLF,
                                       "recover ring ${storage-node}"
                                      ])},
                   {?CMD_DETACH,    "detach ${storage-node}"},
                   {?CMD_SUSPEND,   "suspend ${storage-node}"},
                   {?CMD_RESUME,    "resume ${storage-node}"},
                   {?CMD_DETACH,    "detach ${storage-node}"},
                   {?CMD_START,     "start"},
                   {?CMD_REBALANCE, "rebalance"},
                   %% for Storage
                   {?CMD_COMPACT,   lists:append(
                                      ["compact start ${storage-node} all|${num_of_targets} [${num_of_compact_proc}]", ?CRLF,
                                       "compact suspend ${storage-node}", ?CRLF,
                                       "compact resume  ${storage-node}", ?CRLF,
                                       "compact status  ${storage-node}"
                                      ])},
                   {?CMD_DU, "du ${storage-node}"},
                   %% for Gateway
                   {?CMD_PURGE,  "purge ${path}"},
                   {?CMD_REMOVE, "remove ${gateway-node}"},
                   %% for S3-API
                   %% - user-related
                   {?CMD_CREATE_USER,      "create-user ${user-id} [${password}]"},
                   {?CMD_DELETE_USER,      "delete-user ${user-id}"},
                   {?CMD_UPDATE_USER_ROLE, "update-user-role ${user-id} ${role-id}"},
                   {?CMD_UPDATE_USER_PW,   "update-user-password ${user-id} ${password}"},
                   {?CMD_GET_USERS,        "get-users"},
                   %% - endpoint-related
                   {?CMD_ADD_ENDPOINT,  "add-endpoint ${endpoint}"},
                   {?CMD_SET_ENDPOINT,  "set-endpoint ${endpoint}"},
                   {?CMD_DEL_ENDPOINT,  "delete-endpoint ${endpoint}"},
                   {?CMD_GET_ENDPOINTS, "get-endpoints"},
                   %% - bucket-related
                   {?CMD_ADD_BUCKET,    "add-bucket ${bucket} ${access-key-id}"},
                   {?CMD_DELETE_BUCKET, "delete-bucket ${bucket} ${access-key-id}"},
                   {?CMD_GET_BUCKETS,   "get-buckets"},
                   {?CMD_GET_BUCKET_BY_ACCESS_KEY, "get-bucket ${access-key-id}"},
                   {?CMD_CHANGE_BUCKET_OWNER,      "chown-bucket ${bucket} ${new-access-key-id}"},
                   %% - acl-related
                   {?CMD_UPDATE_ACL, "update-acl ${bucket} ${access-key-id} private|public-read|public-read-write"},
                   %% - multi-dc replication
                   {?CMD_JOIN_CLUSTER,   "join-cluster ${remote-manager-master} ${remote-manager-slave}"},
                   {?CMD_REMOVE_CLUSTER, "remove-cluster ${remote-manager-master} ${remote-manager-slave}"},
                   %% for Manager
                   {?CMD_UPDATE_MANAGERS, "update-managers ${manager-master} ${manager-slave}"},
                   {?CMD_BACKUP_MNESIA,   "backup-mnesia ${backupfilepath}"},
                   {?CMD_RESTORE_MNESIA,  "restore-mnesia ${backupfilepath}"}
                  ]).
-record(cmd_state, {name :: string(),
                    help :: string(),
                    available = true :: boolean()
                   }).

%% du-command-related
-define(NULL_DATETIME, "____-__-__ __:__:__").

%% compaction-related
-define(COMPACT_START,      "start").
-define(COMPACT_SUSPEND,    "suspend").
-define(COMPACT_RESUME,     "resume").
-define(COMPACT_STATUS,     "status").
-define(COMPACT_TARGET_ALL, "all").


%% recover type
-define(RECOVER_BY_FILE, "file").
-define(RECOVER_BY_NODE, "node").
-define(RECOVER_BY_RING, "ring").


%% membership
-define(DEF_NUM_OF_ERROR_COUNT, 2).

%% error
-define(ERROR_COULD_NOT_CONNECT,         "Could not connect").
-define(ERROR_NODE_NOT_EXISTS,           "Node not exist").
-define(ERROR_FAILED_COMPACTION,         "Failed compaction").
-define(ERROR_FAILED_GET_STORAGE_STATS,  "Failed to get storage stats").
-define(ERROR_USER_NOT_FOUND,            "User not found").
-define(ERROR_COULD_NOT_GET_USER,        "Could not get user(s)").
-define(ERROR_COULD_NOT_ADD_USER,        "Could not add a user").
-define(ERROR_COULD_NOT_REMOVE_USER,     "Could not delete a user").
-define(ERROR_COULD_NOT_UPDATE_USER,     "Could not update a user").
-define(ERROR_ENDPOINT_NOT_FOUND,        "Endpoint not found").
-define(ERROR_COULD_NOT_SET_ENDPOINT,    "Could not set an endpoint").
-define(ERROR_COULD_NOT_GET_ENDPOINT,    "Could not get endpoint(s)").
-define(ERROR_COULD_NOT_REMOVE_ENDPOINT, "Could not remove an endpoint").
-define(ERROR_COULD_NOT_ATTACH_NODE,     "Could not attach the node").
-define(ERROR_COULD_NOT_DETACH_NODE,     "Could not detach the node").
-define(ERROR_COULD_NOT_SUSPEND_NODE,    "Could not suspend the node").
-define(ERROR_COULD_NOT_RESUME_NODE,     "Could not resume the node").
-define(ERROR_COULD_NOT_UPDATE_NODE,     "Could not update state of a node").
-define(ERROR_COULD_NOT_UPDATE_MANAGER,  "Could not update manager(s)").
-define(ERROR_COULD_NOT_CREATE_RING,     "Could not create RING").
-define(ERROR_NOT_SPECIFIED_COMMAND,     "Command not exist").
-define(ERROR_NOT_SPECIFIED_NODE,        "Not specified node").
-define(ERROR_NO_CMODE_SPECIFIED,        "Not specified compaction mode").
-define(ERROR_INVALID_PATH,              "Invalid path").
-define(ERROR_INVALID_ARGS,              "Invalid arguments").
-define(ERROR_COULD_NOT_STORE,           "Could not store value").
-define(ERROR_INVALID_BUCKET_FORMAT,     "Invalid bucket format").
-define(ERROR_BUCKET_NOT_FOUND,          "Bucket not found").
-define(ERROR_COULD_NOT_GET_BUCKET,      "Could not get bucket(s)").
-define(ERROR_COULD_NOT_UPDATE_BUCKET,   "Could not update bucket(s)").
-define(ERROR_NOT_STARTED,               "Storage cluster does not start, yet").
-define(ERROR_ALREADY_STARTED,           "Storage cluster already started").
-define(ERROR_STILL_RUNNING,             "still running").
-define(ERROR_MNESIA_NOT_START,          "Mnesia does not start, yet").
-define(ERROR_NOT_SATISFY_CONDITION,     "Not satisfy conditions").
-define(ERROR_TARGET_NODE_NOT_RUNNING,   "Target node does not running").
-define(ERROR_FAILED_BACKUP_MNESIA,      "Failed to backup the mnesia backup file").
-define(ERROR_FAILED_RESTORE_MNESIA,     "Failed to restore the mnesia backup file").
-define(ERROR_FAILED_UPDATE_MANAGERS,    "Failed to update the manager nodes").
-define(ERROR_COULD_NOT_GET_CONF,        "Could not get the system-config").
-define(ERROR_MEMBER_NOT_FOUND,          "Member not found").
-define(ERROR_COULD_NOT_GET_MEMBER,      "Could not get member").
-define(ERROR_COULD_NOT_GET_GATEWAY,     "Could not get gateway(s)").
-define(ERROR_NOT_NEED_REBALANCE,        "Not need rebalance").
-define(ERROR_FAIL_REBALANCE,            "Fail rebalance").
-define(ERROR_FAIL_TO_ASSIGN_NODE,       "Fail to assign node(s)").
-define(ERROR_FAIL_TO_REMOVE_NODE,       "Fail to remove a node").
-define(ERROR_FAIL_TO_SYNCHRONIZE_RING,  "Fail to synchronize RING").
-define(ERROR_FAIL_TO_UPDATE_ACL,        "Fail to update acl of a bucket").
-define(ERROR_FAIL_ACCESS_MNESIA,        "Fail to access mnesia").
-define(ERROR_ALREADY_HAS_SAME_CLUSTER,  "Already has a same neme of cluster").

%% type of console
-define(CONSOLE_CUI,  'cui').
-define(CONSOLE_JSON, 'json').
-define(MOD_TEXT_FORMATTER, 'leo_manager_formatter_text').
-define(MOD_JSON_FORMATTER, 'leo_manager_formatter_json').


%% test values and default values
-define(TEST_USER_ID, "_test_leofs").
-define(TEST_ACCESS_KEY, <<"05236">>).
-define(TEST_SECRET_KEY, <<"802562235">>).

-define(DEF_ENDPOINT_1, <<"localhost">>).
-define(DEF_ENDPOINT_2, <<"s3.amazonaws.com">>).

-define(PROP_MNESIA_NODES, 'leo_manager_mnesia_nodes').


%% MQ related:
-define(QUEUE_ID_FAIL_REBALANCE, 'mq_fail_rebalance').


%% records
%%
-define(AUTH_NOT_YET, 0).
-define(AUTH_USERID_1, 1).
-define(AUTH_USERID_2, 2).
-define(AUTH_PASSWORD, 3).
-define(AUTH_DONE,     5).
-type(auth() :: ?AUTH_NOT_YET  |
                ?AUTH_USERID_1 |
                ?AUTH_USERID_2 |
                ?AUTH_PASSWORD |
                ?AUTH_DONE).

-ifdef(TEST).
-record(state, {formatter         :: atom(),
                auth = ?AUTH_DONE :: auth(),
                user_id = []      :: string(),
                password = []     :: string()
               }).
-else.
-record(state, {formatter         :: atom(),
                auth = ?AUTH_DONE :: auth(),
                user_id = []      :: string(),
                password = []     :: string()
               }).
-endif.

-record(rebalance_info, {
          vnode_id         = -1  :: integer(),
          node                   :: atom(),
          total_of_objects = 0   :: integer(),
          num_of_remains   = 0   :: integer(),
          when_is          = 0   :: integer() %% Posted at
         }).

-record(history, {
          id           :: pos_integer(),
          command = [] :: string(), %% Command
          created = -1 :: integer() %% Created At
         }).

-record(recovery_rebalance_info, {
          id   :: pos_integer(),
          node :: atom(),
          rebalance_info = [] :: list(tuple()),
          timestamp = 0       :: pos_integer()
         }).


%% macros
%%
-define(env_mode_of_manager(),
        case application:get_env(leo_manager, manager_mode) of
            {ok, EnvModeOfManager} -> EnvModeOfManager;
            _ -> 'master'
        end).

-define(env_partner_of_manager_node(),
        case application:get_env(leo_manager, manager_partners) of
            {ok, EnvPartnerOfManagerNode} -> EnvPartnerOfManagerNode;
            _ -> []
        end).

-define(env_listening_port_cui(),
        case application:get_env(leo_manager, port_cui) of
            {ok, EnvCUIListeningPort} -> EnvCUIListeningPort;
            _ -> 10010
        end).

-define(env_listening_port_json(),
        case application:get_env(leo_manager, port_json) of
            {ok, EnvJSONListeningPort} -> EnvJSONListeningPort;
            _ -> 10020
        end).

-define(env_num_of_acceptors_cui(),
        case application:get_env(leo_manager, num_of_acceptors_cui) of
            {ok, EnvCUINumOfAcceptors} -> EnvCUINumOfAcceptors;
            _ -> 3
        end).

-define(env_num_of_acceptors_json(),
        case application:get_env(leo_manager, num_of_acceptors_json) of
            {ok, EnvJSONNumOfAcceptors} -> EnvJSONNumOfAcceptors;
            _ -> 3
        end).

-define(env_console_user_id(),
        case application:get_env(leo_manager, console_user_id) of
            {ok, EnvConsoleUserId} -> EnvConsoleUserId;
            _ -> "leo"
        end).

-define(env_console_password(),
        case application:get_env(leo_manager, console_password) of
            {ok, EnvConsolePassword} -> EnvConsolePassword;
            _ -> "faststorage"
        end).

-define(env_num_of_compact_proc(),
        case application:get_env(leo_manager, num_of_compact_proc) of
            {ok, EnvConsoleNumOfCompactProc} -> EnvConsoleNumOfCompactProc;
            _ -> 3
        end).

-define(env_available_commands(),
        case application:get_env(leo_manager, available_commands) of
            {ok, EnvAvailableCommands} -> EnvAvailableCommands;
            _ -> all
        end).

-define(ratio_of_active_size(_ActiveSize, _TotalSize),
        case (TotalSize < 1) of
            true  -> 0;
            false ->
                erlang:round((_ActiveSize / _TotalSize) * 10000)/100
        end).

-define(env_use_s3_api(),
        %% default is true
        case application:get_env(leo_manager, use_s3_api) of
            {ok, EnvUseS3API} -> EnvUseS3API;
            _ -> true
        end).

-define(DEF_LOG_DIR, "./log/").
-define(env_log_dir(),
        case application:get_env(leo_manager, log_appender) of
            {ok, [{file, Options}|_]} ->
                leo_misc:get_value(path, Options, ?DEF_LOG_DIR);
            _ ->
                ?DEF_LOG_DIR
        end).

-define(DEF_QUEUE_DIR, "./work/queue/").
-define(env_queue_dir(),
        case application:get_env(leo_manager, queue_dir) of
            {ok, _EnvQueueDir} ->
                _EnvQueueDir;
            _ ->
                ?DEF_QUEUE_DIR
        end).
