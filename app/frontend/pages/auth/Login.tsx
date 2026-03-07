import { useForm, Link } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"

export default function Login() {
  const { data, setData, post, processing, errors } = useForm({
    email_address: "",
    password: "",
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    post("/session")
  }

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-muted/40 px-4">
      <div className="mb-8 text-center">
      </div>

      <Card className="w-full max-w-xs rounded-2xl shadow-sm">
        <CardHeader className="pb-4">
          <CardTitle className="text-xl font-semibold">Welcome back!</CardTitle>
        </CardHeader>

        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-1.5">
              <Label htmlFor="email_address">Email</Label>
              <Input
                id="email_address"
                type="email"
                value={data.email_address}
                onChange={(e) => setData("email_address", e.target.value)}
                placeholder="you@example.com"
                autoComplete="email"
                disabled={processing}
                aria-invalid={!!errors.email_address}
                className="h-9 rounded-md text-sm"
              />
              {errors.email_address && (
                <p className="text-xs text-destructive">{errors.email_address}</p>
              )}
            </div>

            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <Label htmlFor="password">Password</Label>
              </div>
              <Input
                id="password"
                type="password"
                value={data.password}
                onChange={(e) => setData("password", e.target.value)}
                autoComplete="current-password"
                disabled={processing}
                aria-invalid={!!errors.password}
                className="h-9 rounded-md text-sm"
              />
              {errors.password && (
                <p className="text-xs text-destructive">{errors.password}</p>
              )}
            </div>

            <Button type="submit" className="w-full mt-2" disabled={processing}>
              {processing ? "Signing in…" : "Sign in"}
            </Button>
          </form>
        </CardContent>

        <CardFooter className="justify-center">
          <p className="text-sm text-muted-foreground">
            Don't have an account?{" "}
            <Link
              href="/registration/new"
              className="text-foreground font-medium underline underline-offset-4 hover:no-underline"
            >
              Create one
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
  )
}
