module ApipieParams::City
  extend Apipie::DSL::Concern

  CITY_HAS_ROLE = {
    city_id: 'Integer',
    role_id: 'Integer',
    action_types_params: {
      action_type_id_1: {
        action_type_param_1: 'value_1',
        action_type_param_2: 'value_2',
        action_type_param_3: 'value_3'
      },
      action_type_id_2: {
          action_type_param_1: 'value_1',
          action_type_param_3: 'value_3'
      }
    }
  }

  CREATE_CITY_DESC = '
  city: {
    id: null,
    name: "MyTown",
    description: "MyTown description.",
    public: true,
    password: null,
    hashed_password: null,
    password_salt: null,
    city_has_roles: null,
    residents: null,
    invitations: null,
    join_requests: null,
    self_generated_result_types: [
      {
        id: 10,
        name: "Residents",
        description: "Residents know at all times which players are alive and which of them are dead.",
        is_self_generated: true
      },
      {
        id: 14,
        name: "Action Type Params",
        description: "Residents know at all times the state of action type parameters (e.g. how many times they can still use a certain action)",
        is_self_generated: true
      }
    ],
    game_end_conditions: [
      {
        id: 1,
        name: "Citizens vs. Mafia",
        description: "The game ends if, at the moment of day start or night start, one of the following conditions are met:\n 1) all mafia members are dead, \n2) mafia members consist >=50% of living population in a city."
      }
    ],
    timezone: 120,
    day_cycles: [
      {
        id: null,
        day_start: 540,
        night_start: 1200,
        day_start_date: "2015-08-09T07:00:36.570Z",
        night_start_date: "2015-08-09T18:00:36.570Z"
      }
    ],
    user_creator_id: 1,
    user_creator_username: "AndrijaCajic",
    active: false,
    paused: false,
    paused_during_day: null,
    last_paused_at: null,
    current_day: null,
    days: null,
    started_at: null,
    finished_at: null,
    created_at: null,
    updated_at: null,
    is_invited: false,
    is_join_requested: false,
    is_member: false,
    is_owner: true,
    role_picks: null
  },
  auth_token: "a03893d89c2f72f910fd24782e5db21f576424dbda6e382f64d92e0551596369"'




  def_param_group :new_city do
    param :city, Hash, :desc => 'City', :required => true do
      param :name, String, :desc => 'City name', :required => true
      param :description, String, :desc => 'City description', :required => false
      param :public, %w[true false], :desc => 'Is it a public or a private game. Default is public.', :required => false
      param :timezone, Integer, :desc => 'Number of minute difference from UTC. For London in the winter (GMT), this value is 0. For CEST – Central European Summer Time, this value is 120. For New York in summer (EDT – Eastern Daylight Time), this value is -240.', :required => true
      param :password, String, :desc => 'City password. Only users that know the password can join. Password is only used if the game is private.', :required => false
      param :self_generated_result_types, Array, of: Hash, :desc => 'Information that player gets without having to do any actions (Self-generated action results). Must be like specified in example. Other scenarios not sufficiently tested.'
    end

  end


  UPDATE_CITY_DESC = '
    city: {
      id: 4,
      name: "test3",
      description: "Testing description.",
      public: false,
      password: "Wyoming",
      hashed_password: null,
      password_salt: null,
      city_has_roles: [
        {
          id: 205,
          city_id: 4,
          role: {
            id: 1,
            affiliation: {
            id: 1,
            name: "Citizens"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            }
            ],
            name: "Citizen",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {
            1: {},
            9: {}
          }
        },
        {
          city_id: 4,
          role: {
            id: 2,
            affiliation: {
            id: 1,
            name: "Citizens"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 2,
              name: "Protect",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {
              number_of_actions_available: -1
              },
              action_result_type: {
              id: 2,
              name: "Protection Result",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            }
            ],
            name: "Doctor",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {
            2: {
            number_of_actions_available: -1
            }
          },
          id: null,
        },
        {
          city_id: 4,
          role: {
            id: 3,
            affiliation: {
            id: 1,
            name: "Citizens"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 3,
              name: "Investigate",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {
              number_of_actions_available: -1
              },
              action_result_type: {
              id: 3,
              name: "Investigation Result",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            }
            ],
            name: "Detective",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {
            3: {
            number_of_actions_available: -1
            }
          },
          id: null,
        },
        {
          city_id: 4,
          role: {
            id: 4,
            affiliation: {
            id: 2,
            name: "Mafia"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 4,
              name: "Mafia Kill",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 4,
              name: "Mafia Kill",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 8,
              name: "Mafia Members",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 9,
              name: "Mafia Members",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            }
            ],
            name: "Mafia",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {},
          id: null
        },
        {
          city_id: 4,
          role: {
            id: 7,
            affiliation: {
            id: 2,
            name: "Mafia"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 7,
              name: "Bomb",
              trigger: {
              id: 4,
              name: "async",
              description: "Triggering is asynchronous."
              },
              is_single_required: false,
              action_type_params: {
              detonation_delay: "5m",
              number_of_collaterals: 1
              },
              action_result_type: {
              id: 8,
              name: "Terrorist Bombing",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true,
            },
            {
              id: 4,
              name: "Mafia Kill",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 4,
              name: "Mafia Kill",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 8,
              name: "Mafia Members",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 9,
              name: "Mafia Members",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            }
            ],
            name: "Terrorist",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {
            7: {
            detonation_delay: "5m",
            number_of_collaterals: 1
            }
          },
          id: null
        },
        {
          city_id: 4,
          role: {
            id: 5,
            affiliation: {
            id: 1,
            name: "Citizens"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 5,
              name: "Reveal Identities",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {
              number_of_actions_available: 1
              },
              action_result_type: {
              id: 5,
              name: "Revealed Identities",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true,
            }
            ],
            name: "Sheriff",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {
            5: {
            number_of_actions_available: 1
            }
          },
          id: null
        },
        {
          city_id: 4,
          role: {
            id: 9,
            affiliation: {
            id: 2,
            name: "Mafia"
            },
            action_types: [
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 4,
              name: "Mafia Kill",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 4,
              name: "Mafia Kill",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 8,
              name: "Mafia Members",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 9,
              name: "Mafia Members",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            }
            ],
            name: "Fugitive",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {},
          id: null
        },
        {
          city_id: 4,
          role: {
            id: 12,
            affiliation: {
            id: 2,
            name: "Mafia"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 4,
              name: "Mafia Kill",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 4,
              name: "Mafia Kill",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 8,
              name: "Mafia Members",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 9,
              name: "Mafia Members",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 13,
              name: "Initiate Revival",
              trigger: {
              id: 4,
              name: "async",
              description: "Triggering is asynchronous."
              },
              is_single_required: false,
              action_type_params: {
              revival_delay: "5m"
              },
              action_result_type: null,
              can_submit_manually: true
            },
            {
              id: 14,
              name: "Revive",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {
              days_until_reveal: 1,
              number_of_actions_available: 1
              },
              action_result_type: {
              id: 17,
              name: "Revival Occurred",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: false
            }
            ],
            name: "Necromancer",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: [
            {
              id: 13,
              affiliation: {
              id: 2,
              name: "Mafia"
              },
              action_types: [
              {
                id: 1,
                name: "Vote",
                trigger: {
                id: 1,
                name: "night start",
                description: "Triggers only at night start."
                },
                is_single_required: false,
                action_type_params: {},
                action_result_type: {
                id: 1,
                name: "Public Vote",
                description: null,
                is_self_generated: false
                },
                can_submit_manually: true
              },
              {
                id: 9,
                name: "Residents",
                trigger: {
                id: 5,
                name: "no trigger",
                description: "Never triggers."
                },
                is_single_required: true,
                action_type_params: {},
                action_result_type: {
                id: 10,
                name: "Residents",
                description: "Residents know at all times which players are alive and which of them are dead.",
                is_self_generated: true
                },
                can_submit_manually: true
              },
              {
                id: 4,
                name: "Mafia Kill",
                trigger: {
                id: 2,
                name: "day start",
                description: "Triggers only at day start."
                },
                is_single_required: false,
                action_type_params: {},
                action_result_type: {
                id: 4,
                name: "Mafia Kill",
                description: null,
                is_self_generated: false
                },
                can_submit_manually: true
              }
              ],
              name: "Zombie",
              is_starting_role: false
            }
            ]
          },
          action_types_params: {
            13: {
            revival_delay: "5m"
            },
            14: {
            days_until_reveal: 1,
            number_of_actions_available: 1
            }
          },
          id: null
        },
        {
          city_id: 4,
          role: {
            id: 6,
            affiliation: {
            id: 1,
            name: "Citizens"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 6,
              name: "Count Votes",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {
              number_of_actions_available: -1
              },
              action_result_type: {
              id: 7,
              name: "Vote Count",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            }
            ],
            name: "Teller",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {
            6: {
            number_of_actions_available: -1
            }
          },
          id: null
          },
          {
          city_id: 4,
          role: {
            id: 8,
            affiliation: {
            id: 1,
            name: "Citizens"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 10,
              name: "Journalist Investigate",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {
              number_of_actions_available: -1
              },
              action_result_type: {
              id: 11,
              name: "Journalist Investigation Result",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            }
            ],
            name: "Journalist",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {
            10: {
            number_of_actions_available: -1
            }
          },
          id: null
        },
        {
          city_id: 4,
          role: {
            id: 10,
            affiliation: {
            id: 1,
            name: "Citizens"
            },
            action_types: [
            {
              id: 1,
              name: "Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 1,
              name: "Public Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            },
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 11,
              name: "Check Identities",
              trigger: {
              id: 2,
              name: "day start",
              description: "Triggers only at day start."
              },
              is_single_required: false,
              action_type_params: {
              number_of_actions_available: 1
              },
              action_result_type: {
              id: 12,
              name: "Identities of Deceased Residents",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            }
            ],
            name: "Deputy",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {
            11: {
            number_of_actions_available: 1
            }
          },
          id: null
          },
          {
          city_id: 4,
          role: {
            id: 11,
            affiliation: {
            id: 1,
            name: "Citizens"
            },
            action_types: [
            {
              id: 9,
              name: "Residents",
              trigger: {
              id: 5,
              name: "no trigger",
              description: "Never triggers."
              },
              is_single_required: true,
              action_type_params: {},
              action_result_type: {
              id: 10,
              name: "Residents",
              description: "Residents know at all times which players are alive and which of them are dead.",
              is_self_generated: true
              },
              can_submit_manually: true
            },
            {
              id: 12,
              name: "Elder Vote",
              trigger: {
              id: 1,
              name: "night start",
              description: "Triggers only at night start."
              },
              is_single_required: false,
              action_type_params: {},
              action_result_type: {
              id: 16,
              name: "Elder Vote",
              description: null,
              is_self_generated: false
              },
              can_submit_manually: true
            }
            ],
            name: "Elder",
            is_starting_role: true,
            role_has_demanded_roles: null,
            implicated_roles: null
          },
          action_types_params: {},
          id: null
        }
      ],
      residents: [
        {
          id: 45,
          user_id: 1,
          name: "AndrijaCajic",
          username: "AndrijaCajic",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 46,
          user_id: 2,
          name: "user2",
          username: "user2",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 47,
          user_id: 3,
          name: "user3",
          username: "user3",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 48,
          user_id: 4,
          name: "user4",
          username: "user4",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 49,
          user_id: 5,
          name: "user5",
          username: "user5",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 50,
          user_id: 28,
          name: "andrija.cajic",
          username: "andrija.cajic",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 51,
          user_id: 6,
          name: "user6",
          username: "user6",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 52,
          user_id: 7,
          name: "user7",
          username: "user7",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 53,
          user_id: 8,
          name: "user8",
          username: "user8",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 54,
          user_id: 9,
          name: "user9",
          username: "user9",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 55,
          user_id: 10,
          name: "user10",
          username: "user10",
          city_id: 4,
          city_name: "test3"
        },
        {
          id: 56,
          user_id: 11,
          name: "user11",
          username: "user11",
          city_id: 4,
          city_name: "test3"
        }
      ],
      invitations: null,
      join_requests: null,
      self_generated_result_types: [
        {
          id: 10,
          name: "Residents",
          description: "Residents know at all times which players are alive and which of them are dead.",
          is_self_generated: true
        },
        {
          id: 14,
          name: "Action Type Params",
          description: "Residents know at all times the state of action type parameters (e.g. how many times they can still use a certain action)",
          is_self_generated: true
        }
      ],
      game_end_conditions: [
        {
          id: 1,
          name: "Citizens vs. Mafia",
          description: "The game ends if, at the moment of day start or night start, one of the following conditions are met:\n 1) all mafia members are dead, \n2) mafia members consist >=50% of living population in a city."
        }
      ],
      timezone: 60,
      day_cycles: [
        {
          id: 13,
          day_start: 540,
          night_start: 1200,
          day_start_date: "2015-08-09T07:00:06.242Z",
          night_start_date: "2015-08-09T18:00:06.242Z"
        }
      ],
      user_creator_id: 1,
      user_creator_username: "AndrijaCajic",
      active: false,
      paused: false,
      paused_during_day: null,
      last_paused_at: null,
      current_day: null,
      days: null,
      started_at: null,
      finished_at: null,
      created_at: "2015-02-22T20:00:29.000Z",
      updated_at: "2015-02-22T20:00:29.000Z",
      is_invited: false,
      is_join_requested: false,
      is_member: true,
      is_owner: true,
      role_picks: null
    },
    auth_token: "a03893d89c2f72f910fd24782e5db21f576424dbda6e382f64d92e0551596369"
'

  CITY_HAS_ROLES_DESC = "
    Role distribution in a city. This is nil when the city is just created, but must be set before the game is started.

    Example:

      city_has_roles: [
        {
          city_id: 2,
          role_id: 2,
          action_types_params: {
            1:{},
            2:{
              number_of_actions_available:-1
            },
            9:{}
          }
        },
        {
          city_id: 2,
          role_id: 3,
          action_types_params: {
            1:{},
            3:{
              number_of_actions_available:4
            },
            9:{}
          }
        },
        {
          city_id: 2,
          role_id: 4,
          action_types_params: {
            1:{},
            4:{},
            8:{},
            9:{}
          }
        }
      ]

    The game cannot be started unless the total number of city_has_roles elements equals the number of residents (players) in the city.
    The value for action_types_params is *optional*. If not set, the default values will be used.

    For action_types_params, Hash specifies the ActionType as the key and the ActionType parameters as the value. Action type parameters are a way to modify (tweak) the properties of a certain role.

    A Doctor (role_id == 2) has 3 action types at his disposal: Vote (1), Protect (2), Residents (9). So, the action_types_params look like this:
      {
        1:{},
        2:{'number_of_actions_available':-1},
        9:{}
      },
    which means that there are no parameters attached to the action type 1 (Vote) and 9 (Residents) but it is specified that user has an unlimited (-1) access to the action of type 2 (Protect).

    Similarly, for a Detective (role_id == 3), the action_types_params look like this:
      {
        1:{},
        3:{'number_of_actions_available':4},
        9:{}
      }
    Action type 3 is Investigate, and it is specified that a user who gets this role will be able to perform the Investigate action only 4 times in the game.

    A list of all possible Action Types can be accessed via */action_type* endpoint. To see all the roles, what role has access to which action types and what are the default action type parameters for each role, use the */roles* endpoint.
  "

  def_param_group :city do
    param :city, Hash, :desc => 'City' do
      param :id, Integer, :desc => 'City id. The id is generated after the city is created.', :required => true
      param :name, String, :desc => 'City name', :required => false
      param :description, String, :desc => 'City description', :required => false
      param :public, %w[true false], :desc => 'Is it a public or a private game. Default is public.', :required => false
      param :timezone, Integer, :desc => 'Number of minute difference from UTC. For London in the winter (GMT), this value is 0. For CEST – Central European Summer Time, this value is 120. For New York in summer (EDT – Eastern Daylight Time), this value is -240.', :required => false
      param :password, String, :desc => 'City password. Only users that know the password can join. Password is only used if the game is private. Password is sent via this key when client is submitting a request to the server. When server is sending password it is being sent via *hashed_password* and *password_salt*. When comparing the match for a *password*, concatenate *password* + *password_salt* into *salted_password* and then check
        sha256_digest(salted_password) == hashed_password
      ', :required => false
      param :hashed_password, String, :desc => 'City hashed password. Used to check if the validity of any password. Perform
        sha256_digest( concatenate(password_you_want_to_validate, password_salt) ) == hashed_password

This will result in a boolean indicating whether the *password_you_want_to_validate* is the correct one or not.', :required => false
      param :password_salt, String, :desc => 'Password salt used in *password* matching with *hashed_password*.'
      param :day_cycles, Array, of: Hash, :desc => 'What is the timing and duration of day and night phases within the game. Example:
  day_cycles: [
    {
      id: 13,
      day_start: 540,
      night_start: 840,
      day_start_date: "2015-08-09T07:00:06.242Z",
      night_start_date: "2015-08-09T18:00:06.242Z"
    },
    {
      id: 14,
      day_start: 1140,
      night_start: 1380,
      day_start_date: "2015-08-09T07:00:06.242Z",
      night_start_date: "2015-08-09T18:00:06.242Z"
    }
  ]

Day cycles like these specify that at 9 AM the game will enter the *day phase*. At 2 PM, the day phase will end and the *night phase* will begin. At 7 PM, the *day phase* will commence again. And at 11 PM, the *night phase* again.
On the next day, the cycle repeats.
', :required => false
      param :city_has_roles, Array, of: Hash, :desc => CITY_HAS_ROLES_DESC, :required => false
      param :self_generated_result_types, Array, of: Hash, :desc => '
Information that player gets without having to do any actions (Self-generated action results). Must be like specified in example. Other scenarios not sufficiently tested.

self_generated_result_types: [
  {
    id: 10,
    name: "Residents",
    description: "Residents know at all times which players are alive and which of them are dead.",
    is_self_generated: true
  },
  {
    id: 14,
    name: "Action Type Params",
    description: "Residents know at all times the state of action type parameters (e.g. how many times they can still use a certain action)",
    is_self_generated: true
  }
]'
      param :game_end_conditions, Array, of: Hash, :desc => '
There is only one game end condition so far. And every game must have at least one Game End Condition.

game_end_conditions: [
  {
    id: 1,
    name: "Citizens vs. Mafia",
    description: "The game ends if, at the moment of day start or night start, one of the following conditions are met:\n 1) all mafia members are dead, \n2) mafia members consist >=50% of living population in a city."
  }
]', :required => false
    end

  end



end