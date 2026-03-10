export type FlashData = {
  notice?: string
  alert?: string
}

export type User = {
  id: string
  email_address: string
  username: string
}

export type SharedProps = {
  user: User | null
  flash: FlashData
}
